From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] net/bridge/br_if.c: fix possible use-after-free in port_carrier_check()
Date: Wed, 21 Feb 2007 17:23:42 +0300
Message-ID: <20070221142342.GB134@tv-sign.ru>
References: <20070220221941.GA707@tv-sign.ru> <20070220162434.72d3ad7b@freekitty> <20070221082345.GB1662@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:38630 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030353AbXBUOXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 09:23:42 -0500
Content-Disposition: inline
In-Reply-To: <20070221082345.GB1662@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21, Jarek Poplawski wrote:
>
> > On Wed, 21 Feb 2007 01:19:41 +0300
> > Oleg Nesterov <oleg@tv-sign.ru> wrote:
> > 
> > > +	p = container_of(work, struct net_bridge_port, carrier_check.work);
> > >  
> > >  	rtnl_lock();
> > > -	p = dev->br_port;
> > > -	if (!p)
> > > -		goto done;
> > >  	br = p->br;
> 
> It doesn't matter very much but I think this would look
> better after the first if check.

OK. I can re-send if this patch is otherwise correct.

Oleg.

