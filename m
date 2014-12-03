From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] ip route: don't assume default route
Date: Wed, 3 Dec 2014 09:17:02 -0800
Message-ID: <20141203091702.75431f80@urahara>
References: <20141202164510.GA9005@mole.pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?UTF-8?q?Pavel=20=C5=A0imerda?= <psimerda@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37844 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750886AbaLCRRN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 12:17:13 -0500
In-Reply-To: <20141202164510.GA9005@mole.pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Dec 2014 17:45:10 +0100
=3D?UTF-8?q?Pavel=3D20=3DC5=3DA0imerda?=3D  <psimerda@redhat.com> wrote=
:

> Just print the help when "ip route del" is called without any other
> arguments.
>=20
> Resolves:
>=20
>  * https://bugzilla.redhat.com/show_bug.cgi?id=3D997965
>=20
> Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
> ---
>  ip/iproute.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/ip/iproute.c b/ip/iproute.c
> index d77b1e3..c171f29 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -975,6 +975,9 @@ static int iproute_modify(int cmd, unsigned flags=
, int argc, char **argv)
>  		argc--; argv++;
>  	}
> =20
> +	if (!dst_ok)
> +		usage();
> +
>  	if (d || nhs_ok)  {
>  		int idx;
> =20

Good catch. Applied
