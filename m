From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/1] Minor code cleanup in drivers/net/r6040.c
Date: Thu, 25 Jun 2009 10:18:40 +0200
Message-ID: <200906251018.40995.florian@openwrt.org>
References: <1245913509-23245-1-git-send-email-michael@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Opdenacker <michael@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:61373 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbZFYISm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 04:18:42 -0400
In-Reply-To: <1245913509-23245-1-git-send-email-michael@free-electrons.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thursday 25 June 2009 09:05:09 Michael Opdenacker, vous avez =C3=A9c=
rit=C2=A0:
>  Replaced '0' by 'bar' in the probe function.
>  The 'bar' variable was already set to '0' and is already
>  used in pci_iomap(). This is cleaner and improves code
>  consistency.
>
> Signed-off-by: Michael Opdenacker <michael@free-electrons.com>

Acked-by: Florian Fainelli <florian@openwrt.org>

> ---
>  drivers/net/r6040.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index ed63d23..b3197e9 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -1112,13 +1112,13 @@ static int __devinit r6040_init_one(struct pc=
i_dev
> *pdev, }
>
>  	/* IO Size check */
> -	if (pci_resource_len(pdev, 0) < io_size) {
> +	if (pci_resource_len(pdev, bar) < io_size) {
>  		printk(KERN_ERR DRV_NAME ": Insufficient PCI resources, aborting\n=
");
>  		err =3D -EIO;
>  		goto err_out;
>  	}
>
> -	pioaddr =3D pci_resource_start(pdev, 0);	/* IO map base address */
> +	pioaddr =3D pci_resource_start(pdev, bar);	/* IO map base address *=
/
>  	pci_set_master(pdev);
>
>  	dev =3D alloc_etherdev(sizeof(struct r6040_private));



--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
