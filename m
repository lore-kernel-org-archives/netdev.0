From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: converting generic HDLC to use netif_dormant*()
Date: Thu, 13 Jul 2006 21:18:58 -0700 (PDT)
Message-ID: <20060713.211858.15263760.davem@davemloft.net>
References: <m3veq3suve.fsf@defiant.localdomain>
	<20060712.134632.06531928.davem@davemloft.net>
	<20060713194504.f6c97d47.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, jeff@garzik.org, netdev@vger.kernel.org,
	paulkf@microgate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53432
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161244AbWGNESy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 00:18:54 -0400
To: akpm@osdl.org
In-Reply-To: <20060713194504.f6c97d47.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Thu, 13 Jul 2006 19:45:04 -0700

> On Wed, 12 Jul 2006 13:46:32 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Krzysztof Halasa <khc@pm.waw.pl>
> > Date: Tue, 11 Jul 2006 23:18:45 +0200
> > 
> > > This patch converts generic HDLC (and WAN drivers using it) from
> > > hdlc_set_carrier() to netif_dormant*() interface.
> > > WAN hardware drivers should now use netif_carrier_on|off() like
> > > other network drivers.
> > > 
> > > Please apply. Thanks.
> > > 
> > > Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> > 
> > Applied.
> 
> Broken ;)
> 
> WARNING: "hdlc_set_carrier" [drivers/char/synclinkmp.ko] undefined!
> WARNING: "hdlc_set_carrier" [drivers/char/synclink_gt.ko] undefined!
> WARNING: "hdlc_set_carrier" [drivers/char/synclink.ko] undefined!
> WARNING: "hdlc_set_carrier" [drivers/char/pcmcia/synclink_cs.ko] undefined!

Krzysztof please provide a fix for this, this function you added
calls to does not exist anywhere, which suggests you either produced
a patch against a different tree than the current one or you didn't
even compile test this patch.

Thanks.
