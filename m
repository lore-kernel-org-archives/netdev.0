From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 17:04:12 +0200
Message-ID: <20100915150412.GA679@redhat.com>
References: <20100914162952.GB13560@redhat.com>
 <1284483745.13351.71.camel@localhost.localdomain>
 <20100914182707.GB15549@redhat.com>
 <1284490143.13351.82.camel@localhost.localdomain>
 <20100914190156.GA16037@redhat.com>
 <1284492983.13351.95.camel@localhost.localdomain>
 <20100915051241.GA25340@redhat.com>
 <1284531675.24603.259.camel@localhost.localdomain>
 <20100915101000.GB28016@redhat.com>
 <1284562354.2573.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293Ab0IOPKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 11:10:20 -0400
Content-Disposition: inline
In-Reply-To: <1284562354.2573.12.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 15, 2010 at 07:52:34AM -0700, Shirley Ma wrote:
> On Wed, 2010-09-15 at 12:10 +0200, Michael S. Tsirkin wrote:
> > Another issue is that macvtap can be bound to almost
> > anything, including e.g. a tap device or a bridge,
> > which might hang on to skb fragments for unlimited time.
> > Zero copy TX won't easily work there.
> > I can imagine either somehow triggering a data copy after the
> > fact (hard), or detecting such devices and avoiding
> > zero copy (unfortunate for guest to guest, and drivers
> > will need tuning).
> 
> So far macvtap zero copy patch is limited to lower devices supports high
> memory DMA, it doesn't apply to a tap device or a bridge.

Okay. What about macvtap in bridge mode?

> > >  Don't you think once I address vhost_add_used_and_signal update
> > > issue, it is a simple and complete patch for macvtap TX zero copy?
> > > 
> > > Thanks
> > > Shirley
> > 
> > I like the fact that the patch is simple. Unfortunately
> > I suspect it'll stop being simple by the time it's complete :) 
> 
> I can make a try. :)
> 
> Thanks
> Shirley
