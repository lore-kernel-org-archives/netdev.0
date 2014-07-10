From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net v2 5/7] net: cpmac: fix missing a blank line after
 declarations
Date: Thu, 10 Jul 2014 08:08:39 -0500
Message-ID: <20140710130839.GE15340@saruman.home>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
 <1404970545-26508-6-git-send-email-varkabhadram@gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="u5E4XgoOPWr4PD9E"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<linux@rainbow-software.org>, <balbi@ti.com>,
	<george.cherian@ti.com>, <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:51728 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbaGJNJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 09:09:37 -0400
Content-Disposition: inline
In-Reply-To: <1404970545-26508-6-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--u5E4XgoOPWr4PD9E
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 10, 2014 at 11:05:43AM +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>=20
> This patch insert a blank line after declaration
>=20
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Reviewed-by: Felipe Balbi <balbi@ti.com>

> ---
>  drivers/net/ethernet/ti/cpmac.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cp=
mac.c
> index 1520c19..3d3ead4 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -224,6 +224,7 @@ static void cpmac_dump_regs(struct net_device *dev)
>  {
>  	int i;
>  	struct cpmac_priv *priv =3D netdev_priv(dev);
> +
>  	for (i =3D 0; i < CPMAC_REG_END; i +=3D 4) {
>  		if (i % 16 =3D=3D 0) {
>  			if (i)
> @@ -238,6 +239,7 @@ static void cpmac_dump_regs(struct net_device *dev)
>  static void cpmac_dump_desc(struct net_device *dev, struct cpmac_desc *d=
esc)
>  {
>  	int i;
> +
>  	netdev_dbg(dev, "desc[%p]:", desc);
>  	for (i =3D 0; i < sizeof(*desc) / 4; i++)
>  		pr_debug(" %08x", ((u32 *)desc)[i]);
> @@ -248,6 +250,7 @@ static void cpmac_dump_all_desc(struct net_device *de=
v)
>  {
>  	struct cpmac_priv *priv =3D netdev_priv(dev);
>  	struct cpmac_desc *dump =3D priv->rx_head;
> +
>  	do {
>  		cpmac_dump_desc(dev, dump);
>  		dump =3D dump->next;
> @@ -257,6 +260,7 @@ static void cpmac_dump_all_desc(struct net_device *de=
v)
>  static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
>  {
>  	int i;
> +
>  	netdev_dbg(dev, "skb 0x%p, len=3D%d\n", skb, skb->len);
>  	for (i =3D 0; i < skb->len; i++) {
>  		if (i % 16 =3D=3D 0) {
> @@ -681,6 +685,7 @@ static void cpmac_clear_rx(struct net_device *dev)
>  	struct cpmac_priv *priv =3D netdev_priv(dev);
>  	struct cpmac_desc *desc;
>  	int i;
> +
>  	if (unlikely(!priv->rx_head))
>  		return;
>  	desc =3D priv->rx_head;
> @@ -703,6 +708,7 @@ static void cpmac_clear_tx(struct net_device *dev)
>  {
>  	struct cpmac_priv *priv =3D netdev_priv(dev);
>  	int i;
> +
>  	if (unlikely(!priv->desc_ring))
>  		return;
>  	for (i =3D 0; i < CPMAC_QUEUES; i++) {
> @@ -821,6 +827,7 @@ static void cpmac_tx_timeout(struct net_device *dev)
>  static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cm=
d)
>  {
>  	struct cpmac_priv *priv =3D netdev_priv(dev);
> +
>  	if (!(netif_running(dev)))
>  		return -EINVAL;
>  	if (!priv->phy)
> @@ -1181,6 +1188,7 @@ fail:
>  static int cpmac_remove(struct platform_device *pdev)
>  {
>  	struct net_device *dev =3D platform_get_drvdata(pdev);
> +
>  	unregister_netdev(dev);
>  	free_netdev(dev);
>  	return 0;
> --=20
> 1.7.9.5
>=20

--=20
balbi

--u5E4XgoOPWr4PD9E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvpBXAAoJEIaOsuA1yqRESoIQAKbalqWu3pOIBilbMaj0512t
i5Ez9y3rfTlKWieq67aG47Tv/UMa4UCMxteHRILq1taLc9EelxXgLN3Ck5xdJSYk
EdMc0t80Vje9fXesRy9/0moBAxHbzBbNL0Xoqi1vcrbDTGKMB/PNYEX2lTEpzXjk
IlDV2uj+xY6dVNbPLjaSvE025BafUsEeaw32WONnGtzGRE+sspcO4kP/vB4UJx59
ZGe4I1vFDK/DWADG8SmeFv9SHBCE8S5SJmdcnlGFcroAJE/fOEyvxKMMvO2c8dmp
HKCgoJlM6GFiM4bVH1mCSv5F5nGSjXbCYSja6Wu8lrvSDdHGED37U0l0WvVUDG3g
3qmbyQ8VOPJrdiTfdhfFdLsNoIXJTJbkSk6eFjgNvbl+p5eEmBJUTN/Fnejmg6az
9ATQiGrs8tOyf0dOqcvPzrC9X0V7U/LOsoNQIg1F0Q4k69WHf/AIrfYsbx7GcFRh
hbzGPy1P42aEV0ZVrr30yWNu1ckUd+GE9mQrqI0R2Ep/GIcXnaTSp4Nla63vpjgj
T/kfE3OBc/PbZoqs4ivv3mytlb5cDVeOaGQ6mulNxSaM8Bg+SyZhrI44T2qULRN3
sLN8CvvrmYGZtzLqFsyMkRSpCdJCvvaOeRiT0OGd7d88m+XVUEcxA9Wwdg/rmeZe
oUA0wTGD36LUeBdNs7Ke
=Yae2
-----END PGP SIGNATURE-----

--u5E4XgoOPWr4PD9E--
