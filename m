From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Xen-devel] [PATCH net-next 4/5] xen: convert to 64 bit stats
 interface
Date: Tue, 21 Jun 2011 08:29:58 -0700
Message-ID: <20110621082958.3136c7b2@nehalam.ftrdhcpuser.net>
References: <20110620203506.363818794@vyatta.com>
	<20110620203602.929964665@vyatta.com>
	<1308665154.6920.46.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37061 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab1FUPaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 11:30:01 -0400
In-Reply-To: <1308665154.6920.46.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 15:05:54 +0100
Ian Campbell <Ian.Campbell@citrix.com> wrote:

> On Mon, 2011-06-20 at 21:35 +0100, Stephen Hemminger wrote:
> > Convert xen driver to 64 bit statistics interface.
> > Use stats_sync to ensure that 64 bit update is read atomically
> > on 32 bit platform. Put hot statistics into per-cpu table.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Thanks Stephen.
> 
> > @@ -867,12 +882,13 @@ static int handle_incoming_queue(struct
> >  		if (checksum_setup(dev, skb)) {
> >  			kfree_skb(skb);
> >  			packets_dropped++;
> > -			dev->stats.rx_errors++;
> 
> Why is this dropped? We should be counting these somehow, I think.
> 
> [...]
> 
> > >From shemminger@vyatta.com Mon Jun 20 13:36:03 2011
> > Message-Id: <20110620203603.019928129@vyatta.com>
> > User-Agent: quilt/0.48-1
> > Date: Mon, 20 Jun 2011 13:35:11 -0700
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > To: davem@davemloft.net
> > Cc: netdev@vger.kernel.org
> > Subject: [PATCH net-next 5/5] ifb: convert to 64 bit stats
> > References: <20110620203506.363818794@vyatta.com>
> > Content-Disposition: inline; filename=ifb-stats64.patch
> > 
> > Convert input functional block device to use 64 bit stats.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > ---
> > v2 - add stats_sync
> > 
> > 
> > --- a/drivers/net/ifb.c	2011-06-09 14:39:25.000000000 -0700
> > +++ b/drivers/net/ifb.c	2011-06-20 13:30:30.135992612 -0700
> 
> This entire patch was appended in the mail I got -- something up with
> your scripting?

Bad mbox file to quilt, merged two patches
