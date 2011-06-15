From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 1/2] batman-adv: count_real_packets() in
	batman-adv assumes char is signed
Date: Wed, 15 Jun 2011 07:59:15 +0200
Message-ID: <201106150759.15643.sven@narfation.org>
References: <20110614235132.3724.57632.stgit@warthog.procyon.org.uk>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3529075.mEVmQ899UY";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20110614235132.3724.57632.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart3529075.mEVmQ899UY
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

David Howells wrote:
> count_real_packets() in batman-adv assumes char is signed, and returns -1
> through it:
>=20
> net/batman-adv/routing.c: In function 'receive_bat_packet':
> net/batman-adv/routing.c:739: warning: comparison is always false due to
> limited range of data type
>=20
> Use int instead.
>=20

[...]
> -static char count_real_packets(struct ethhdr *ethhdr,
> -			       struct batman_packet *batman_packet,
> -			       struct hard_iface *if_incoming)
> +static int count_real_packets(struct ethhdr *ethhdr,
> +			      struct batman_packet *batman_packet,
> +			      struct hard_iface *if_incoming)
>  {


This one doesn't apply on linux-next/net-next-2.6, but I will fix it by han=
d.

Thanks,
	Sven

--nextPart3529075.mEVmQ899UY
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJN+EozAAoJEF2HCgfBJntG1vsP+wTsooSe/vh/kc2V2Y19JYLq
0TtvDWqKGUEyA68VakxspRhWfCNuKBhsK1rcR3oHnE5Kvx0SvEqolpR30UMBxPXu
8wIvqWTUNBmfQL/aS089MqXn6Bn1zP4PJS6ovfA+D62t5J4JlEuxmAN6VkIDYMg6
8gVfSeRLUFXBXQRbs3gmI39wZzt3y8ODR2YJEST6PsZJpGyammqq4Q9LM1dfz7ZT
xPtofQmVffRplJ++i5viCvo0oud/8YXom65Zc9ff/ZC+rdAMBfLOocGJ2QmSKnK4
rOH8opU+8W3paHVWwnofueTIOH4sB7UiUcNFrnzntp02NrgBbnD+2EW14Z4KrGaJ
VSHgTmMCU2H05TKLaJInHPnEQLsi/4trEvNYT5Uov5jUI5DZnxs4813znjULwjsT
1f0zSOUw/p66URyLH4TEMA1zCm5JjRHJnaLQSjnSO21UQqB186INHleThZXMqVEG
AtUcaGnNnF5G045cx2Z/zFtRXv3g4NpGZJQOzWqyEyhzrY6MhLtbFc4cCbJE21ku
ahfShkJp0Gf2BL/wFoXiiXu8j2vHuC/WtJii6lF8QeJgFtJkoKfMLXVmya8OZ81w
XQrJvbDTfh3DTxhTmhV4CIFEGDNUCULL7tMhuKemqM8ulRq8EOtEm13FMdjEGk/7
Y9tfbIFyHWTQ5trJiSky
=jrRk
-----END PGP SIGNATURE-----

--nextPart3529075.mEVmQ899UY--
