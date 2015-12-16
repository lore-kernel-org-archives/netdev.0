From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH iproute2] ipv6: allow setting stable_secret mode
Date: Wed, 16 Dec 2015 17:56:55 +0100
Message-ID: <64C7B1E3-1F0C-4472-91A9-9D6DE5206D6A@mork.no>
References: <1450265408-20510-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37327 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965891AbbLPQ4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 11:56:04 -0500
In-Reply-To: <1450265408-20510-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On December 16, 2015 12:30:08 PM CET, Hannes Frederic Sowa <hannes@stre=
ssinduktion.org> wrote:
>Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>---
> ip/iplink.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/ip/iplink.c b/ip/iplink.c
>index f30de86d1858a0..e824082f7d8149 100644
>--- a/ip/iplink.c
>+++ b/ip/iplink.c
>@@ -84,7 +84,7 @@ void iplink_usage(void)
> 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
> 	fprintf(stderr, "			  [ master DEVICE ]\n");
> 	fprintf(stderr, "			  [ nomaster ]\n");
>-	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
>+	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret }
>]\n");
> 	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
>	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]
>[master DEV] [type TYPE]\n");
>=20
>@@ -176,6 +176,8 @@ static int get_addr_gen_mode(const char *mode)
> 		return IN6_ADDR_GEN_MODE_EUI64;
> 	if (strcasecmp(mode, "none") =3D=3D 0)
> 		return IN6_ADDR_GEN_MODE_NONE;
>+	if (strcasecmp(mode, "stable_secret") =3D=3D 0)
>+		return IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
> 	return -1;
> }
>=20

Ah, didn't notice this before I sent my similar patch. Sorry about that=
=2E

But FWIW, I really don't like the renaming you do here.=20
If the mode is 'stable_privacy', then it should be known
by that name here as well.


Bj=C3=B8rn
