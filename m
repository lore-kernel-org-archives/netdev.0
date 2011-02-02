From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 07:42:51 -0800
Message-ID: <1296661371.25430.13.camel@localhost.localdomain>
References: <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <20110202062950.GD3818@redhat.com>
	 <1296630891.26937.870.camel@localhost.localdomain>
	 <1296632029.26937.871.camel@localhost.localdomain>
	 <20110202104946.GC8505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:57245 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439Ab1BBPoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 10:44:15 -0500
In-Reply-To: <20110202104946.GC8505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-02 at 12:49 +0200, Michael S. Tsirkin wrote:
> On Tue, Feb 01, 2011 at 11:33:49PM -0800, Shirley Ma wrote:
> > On Tue, 2011-02-01 at 23:14 -0800, Shirley Ma wrote:
> > > w/i guest change, I played around the parameters,for example: I
> could
> > > get 3.7Gb/s with 42% CPU BW increasing from 2.5Gb/s for 1K message
> > > size,
> > > w/i dropping packet, I was able to get up to 6.2Gb/s with similar
> CPU
> > > usage. 
> > 
> > I meant w/o guest change, only vhost changes. Sorry about that.
> > 
> > Shirley
> 
> Ah, excellent. What were the parameters? 

I used half of the ring size 129 for packet counters, but the
performance is still not as good as dropping packets on guest, 3.7 Gb/s
vs. 6.2Gb/s.

Shirley

