From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] vxlan: if_arp: introduce ARPHRD_VXLANGPE
Date: Fri, 6 May 2016 17:11:34 +0900
Message-ID: <20160506081128.GA23137@penelope.isobedori.kobe.vergenet.net>
References: <1462466204-3534-1-git-send-email-cascardo@redhat.com>
 <20160505213141.7ad29ebd@griffin>
 <20160505195643.GA14919@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33353 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbcEFILn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 04:11:43 -0400
Received: by mail-pa0-f51.google.com with SMTP id xk12so45508067pac.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 01:11:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160505195643.GA14919@indiana.gru.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 04:56:43PM -0300, Thadeu Lima de Souza Cascardo wrote:
> On Thu, May 05, 2016 at 09:31:41PM +0200, Jiri Benc wrote:
> > On Thu,  5 May 2016 13:36:44 -0300, Thadeu Lima de Souza Cascardo wrote:
> > > Use ARPHRD_VXLANGPE to identify VxLAN GPE interfaces. This is going to be used
> > > to allow GPE interfaces to be added as openvswitch ports.
> > 
> > What's wrong with ARPHRD_NONE? I don't think we need a separate type
> > for VXLAN-GPE. Just use ARPHRD_NONE in ovs and things should work, for
> > all ARPHRD_NONE interfaces as a bonus.
> > 
> 
> That's fine for me. I looked quickly at the few devices using ARPHRD_NONE in
> upstream kernel, not sure if there are broken out-of-tree drivers out there. And
> should we care?

It seems unlikely to me that we should.
