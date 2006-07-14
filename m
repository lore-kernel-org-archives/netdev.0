From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] WAN: converting generic HDLC to use netif_dormant*()
Date: Thu, 13 Jul 2006 19:45:04 -0700
Message-ID: <20060713194504.f6c97d47.akpm@osdl.org>
References: <m3veq3suve.fsf@defiant.localdomain>
	<20060712.134632.06531928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, jeff@garzik.org, netdev@vger.kernel.org,
	Paul Fulghum <paulkf@microgate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27306 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161192AbWGNCpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 22:45:47 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060712.134632.06531928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Jul 2006 13:46:32 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Krzysztof Halasa <khc@pm.waw.pl>
> Date: Tue, 11 Jul 2006 23:18:45 +0200
> 
> > This patch converts generic HDLC (and WAN drivers using it) from
> > hdlc_set_carrier() to netif_dormant*() interface.
> > WAN hardware drivers should now use netif_carrier_on|off() like
> > other network drivers.
> > 
> > Please apply. Thanks.
> > 
> > Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> 
> Applied.

Broken ;)

WARNING: "hdlc_set_carrier" [drivers/char/synclinkmp.ko] undefined!
WARNING: "hdlc_set_carrier" [drivers/char/synclink_gt.ko] undefined!
WARNING: "hdlc_set_carrier" [drivers/char/synclink.ko] undefined!
WARNING: "hdlc_set_carrier" [drivers/char/pcmcia/synclink_cs.ko] undefined!

