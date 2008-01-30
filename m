From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [git patches] net driver fixes
Date: Wed, 30 Jan 2008 11:21:16 +0100
Message-ID: <20080130102116.GA20846@uranus.ravnborg.org>
References: <20080130094440.GA4652@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:42058 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759900AbYA3KVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 05:21:17 -0500
Content-Disposition: inline
In-Reply-To: <20080130094440.GA4652@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Jeff Garzik (1):
>       [netdrvr] sis190: build fix

But you did it wrong...
sis190.c b/drivers/net/sis190.c
> index b570402..2e9e88b 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
> @@ -326,7 +326,7 @@ static const struct {
>  	{ "SiS 191 PCI Gigabit Ethernet adapter" },
>  };
>  
> -static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
> +static struct pci_device_id sis190_pci_tbl[] = {
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
>  	{ 0, },

The __devinitdata is OK, it is the following _devinitdata that had to be _devinitconst.

	Sam
