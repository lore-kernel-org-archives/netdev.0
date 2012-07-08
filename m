From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] r6040: use module_pci_driver macro
Date: Sun, 8 Jul 2012 23:39:17 +0200
Message-ID: <201207082339.17996.florian@openwrt.org>
References: <1341763077-938-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Devendra Naga <devendra.aaru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62525 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab2GHVjN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 17:39:13 -0400
Received: by eaak11 with SMTP id k11so4127133eaa.19
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2012 14:39:12 -0700 (PDT)
In-Reply-To: <1341763077-938-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 08 juillet 2012 17:57:57, Devendra Naga a =E9crit :
> as the manual of module_pci_driver says that
> it can be used when the init and exit functions of
> the module does nothing but the pci_register_driver
> and pci_unregister_driver.
>=20
> use it for rdc's r6040 driver, as the init and exit
> paths does as above, and also this reduces a little
> amount of code.
>=20
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Acked-by: Florian Fainelli <florian@openwrt.org>

> ---
>  drivers/net/ethernet/rdc/r6040.c |   15 +--------------
>  1 file changed, 1 insertion(+), 14 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/rdc/r6040.c
> b/drivers/net/ethernet/rdc/r6040.c index 9acc026..557a265 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -1277,17 +1277,4 @@ static struct pci_driver r6040_driver =3D {
>  	.remove		=3D __devexit_p(r6040_remove_one),
>  };
>=20
> -
> -static int __init r6040_init(void)
> -{
> -	return pci_register_driver(&r6040_driver);
> -}
> -
> -
> -static void __exit r6040_cleanup(void)
> -{
> -	pci_unregister_driver(&r6040_driver);
> -}
> -
> -module_init(r6040_init);
> -module_exit(r6040_cleanup);
> +module_pci_driver(r6040_driver);

--=20
=46lorian
