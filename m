From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: [PATCH 3/3] ep93xx_eth: don't report RX FIFO overrun errors
Date: Sun, 29 Oct 2006 11:41:00 -0700
Message-ID: <200610291141.00866.rayl@mail.com>
References: <20061029130649.GD6900@xi.wantstofly.org>
 <200610291115.29428.rayl@mail.com> <20061029182253.GE7055@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]:22147 "EHLO
	pd4mo3so.prod.shaw.ca") by vger.kernel.org with ESMTP
	id S932407AbWJ2SmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 13:42:09 -0500
Received: from pd5mr5so.prod.shaw.ca
 (pd5mr5so-qfe3.prod.shaw.ca [10.0.141.181]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0J7W001PIUKF5300@l-daemon> for netdev@vger.kernel.org; Sun,
 29 Oct 2006 11:41:03 -0700 (MST)
Received: from pn2ml5so.prod.shaw.ca ([10.0.121.149])
 by pd5mr5so.prod.shaw.ca (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar
 15 2004)) with ESMTP id <0J7W006EVUKE3YS0@pd5mr5so.prod.shaw.ca> for
 netdev@vger.kernel.org; Sun, 29 Oct 2006 11:41:03 -0700 (MST)
Received: from ray.lehtiniemi.com ([68.147.121.172])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0J7W00IHHUKE1G84@l-daemon> for netdev@vger.kernel.org; Sun,
 29 Oct 2006 11:41:02 -0700 (MST)
In-reply-to: <20061029182253.GE7055@xi.wantstofly.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 29 October 2006 11:22, Lennert Buytenhek wrote:

> > Also, is it possible for any other error bits to be set at the same
> > time as OE?  such bits would not be printed to the log in this case.
>
> Not sure, but arguably, this wouldn't be very interesting.  Actually,
> now I'm wondering whether we should just remove the printk altogether.

i don't see why we need a printk... the error counters _should_ be sufficient.

ray
