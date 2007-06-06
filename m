From: jes@trained-monkey.org (Jes Sorensen)
Subject: Re: [PATCH] acenic: SET_NETDEV_DEV is always there these days
Date: Wed, 6 Jun 2007 10:35:38 -0400
Message-ID: <18022.50746.294140.591576@jaguar.mkp.net>
References: <Pine.LNX.4.62.0706061601420.25857@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	trivial@kernel.org
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaguar.mkp.net ([192.139.46.146]:52871 "EHLO jaguar.mkp.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbXFFPEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 11:04:09 -0400
In-Reply-To: <Pine.LNX.4.62.0706061601420.25857@pademelon.sonytel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Geert" == Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com> writes:

Geert> acenic: SET_NETDEV_DEV is always there these days

Geert> Signed-off-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

Signed-off-by: Jes Sorensen <jes@sgi.com>

Geert> --- Disclaimer: not tested at all

Geert> --- a/drivers/net/acenic.c +++ b/drivers/net/acenic.c @@ -159,10
Geert> +159,6 @@ static struct pci_device_id acenic_pci_t };
Geert> MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
 
Geert> -#ifndef SET_NETDEV_DEV -#define SET_NETDEV_DEV(net, pdev) do{}
Geert> while(0) -#endif - #define ace_sync_irq(irq) synchronize_irq(irq)
 
Geert>  #ifndef offset_in_page

Geert> Gr{oetje,eeting}s,

Geert> 						Geert

Geert> -- Geert Uytterhoeven -- Sony Network and Software Technology
Geert> Center Europe (NSCE) Geert.Uytterhoeven@sonycom.com ------- The
Geert> Corporate Village, Da Vincilaan 7-D1 Voice +32-2-7008453 Fax
Geert> +32-2-7008622 ---------------- B-1935 Zaventem, Belgium
