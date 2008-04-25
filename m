From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Removing dead code in /drivers/net/wan/hdlc_fr.c
Date: Fri, 25 Apr 2008 02:01:58 -0400
Message-ID: <481173D6.6080609@garzik.org>
References: <m3lk385tx4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58467 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755575AbYDYGCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:02:01 -0400
In-Reply-To: <m3lk385tx4.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> From: C=E9dric Augonnet <Cedric.Augonnet@ens-lyon.fr>
>=20
> Removing dead code in /drivers/net/wan/hdlc_fr.c
>    =20
> The local variable "prefix" is never used anymore, and the content of
> this string appears a bit later, directly in a call to "alloc_netdev"
> after doing exactly the same if/else test. So there seems to be no
> point keeping those 4 lines anymore.
>    =20
> Signed-off-by: C=E9dric Augonnet <cedric.augonnet@ens-lyon.org>
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>
>=20
> diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
> index c4ab032..520bb0b 100644
> --- a/drivers/net/wan/hdlc_fr.c
> +++ b/drivers/net/wan/hdlc_fr.c
> @@ -1090,10 +1090,6 @@ static int fr_add_pvc(struct net_device *frad,=
 unsigned int dlci, int type)
>  	pvc_device *pvc =3D NULL;
>  	struct net_device *dev;
>  	int result, used;
> -	char * prefix =3D "pvc%d";
> -
> -	if (type =3D=3D ARPHRD_ETHER)
> -		prefix =3D "pvceth%d";
> =20
>  	if ((pvc =3D add_pvc(frad, dlci)) =3D=3D NULL) {

applied


