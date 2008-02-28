From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO
	frame   size
Date: Thu, 28 Feb 2008 08:29:19 +0000
Message-ID: <20080228082919.GB7067@ff.dom.local>
References: <20080227172606.4446.97153.stgit@localhost.localdomain> <20080228080746.GA7067@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:36449 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbYB1I2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 03:28:15 -0500
Received: by ug-out-1314.google.com with SMTP id z38so186103ugc.16
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 00:28:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080228080746.GA7067@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2008 at 08:07:46AM +0000, Jarek Poplawski wrote:
> On 27-02-2008 18:26, PJ Waskiewicz wrote:
> ...
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index a2f0032..3bf825b 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -620,6 +620,7 @@ struct net_device
> >  
> >  	/* Partially transmitted GSO packet. */
> >  	struct sk_buff		*gso_skb;
> > +	u16			max_gso_frame_size;

...And since it looks like not very often used - maybe it could be
placed a bit lower?

Jarek P.
