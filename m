From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Documentation: broadcom-bcmgenet: fix address and cells properties
Date: Mon, 17 Feb 2014 20:37:24 -0800
Message-ID: <1632803.vUVKaAhEaF@lenovo>
References: <1392683255-28136-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52556 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbaBREh1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 23:37:27 -0500
Received: by mail-ob0-f174.google.com with SMTP id uy5so17956761obc.19
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 20:37:27 -0800 (PST)
In-Reply-To: <1392683255-28136-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 f=E9vrier 2014, 16:27:35 Florian Fainelli a =E9crit :
> This patch fixes a typo in the Device Tree binding for the
> leading '#'.
>=20
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---

=46orgot to mention that this patch is for the net-next tree. Thanks!

>  Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt | 8 ++++=
----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.=
txt
> b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt index
> 88c3d04..25339ee 100644
> --- a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
> +++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
> @@ -10,8 +10,8 @@ Required properties:
>  - phy-mode: String, operation mode of the PHY interface. Supported v=
alues
> are "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePA=
PR
> "phy-connection-type" values
> -- address-cells: should be 1
> -- size-cells: should be 1
> +- #address-cells: should be 1
> +- #size-cells: should be 1
>=20
>  Optional properties:
>  - clocks: When provided, must be two phandles to the functional cloc=
ks
> nodes @@ -42,8 +42,8 @@ MDIO bus node required properties:
>    parent node compatible property (e.g: brcm,genet-v4 pairs with
>    brcm,genet-mdio-v4)
>  - reg: address and length relative to the parent node base register =
address
> -- address-cells: address cell for MDIO bus addressing, should be 1 -=
-
> size-cells: size of the cells for MDIO bus addressing, should be 0 +-
> #address-cells: address cell for MDIO bus addressing, should be 1 +-
> #size-cells: size of the cells for MDIO bus addressing, should be 0
>=20
>  Ethernet PHY node properties:

--=20
=46lorian
