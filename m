From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH UPDATE]  Extract chip specific code out of lasi_82596.c
Date: Wed, 27 Jun 2007 21:39:41 +0200
Message-ID: <20070627193941.GA7748@electric-eye.fr.zoreil.com>
References: <20070626205145.GA21014@alpha.franken.de> <20070626214755.GA11551@electric-eye.fr.zoreil.com> <20070626221736.GA22252@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jgarzik@pobox.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39228 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbXF0Tlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 15:41:50 -0400
Content-Disposition: inline
In-Reply-To: <20070626221736.GA22252@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer <tsbogend@alpha.franken.de> :
> On Tue, Jun 26, 2007 at 11:47:55PM +0200, Francois Romieu wrote:
> > Thomas Bogendoerfer <tsbogend@alpha.franken.de> :
> > [...]
> > > +static inline void init_rx_bufs(struct net_device *dev)
[...]
> > The driver could use netdev_alloc_skb.
> 
> what's the advantage ?

Setting of skb->dev.

-- 
Ueimor
