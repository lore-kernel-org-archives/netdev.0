From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2 add hoplimit parsing and update usage and documentation
Date: Tue, 06 Oct 2009 19:14:28 +0200
Message-ID: <4ACB7AF4.4070207@gmail.com>
References: <1254836434.544524.27946.nullmailer@watson.codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ori Finkelman <ori@comsleep.com>,
	Andreas Henriksson <andreas@fatal.se>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47717 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbZJFRPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 13:15:12 -0400
In-Reply-To: <1254836434.544524.27946.nullmailer@watson.codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef a =E9crit :
> From: Gilad Ben-Yossef <gilad@codefidence.com>
>=20
> - Parse and handle the hoplimit ip route option and add it to the usa=
ge=20
>   line and documentation.
>=20
> - Add the missing reordering ip route option to the usage line.
>=20
> - Add documentation for initcwnd ip route option.
>=20
> Tested by setting hoplimit and retreiving it via "show".=20
>=20
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> [ported to HEAD, fixed a bug with hoplimit lock handling, added docum=
entation]
> Signed-off-by: Ori Finkelman <ori@comsleep.com>
> Signed-off-by: Yony Amit <yony@comsleep.com>
>=20

> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -13,6 +13,8 @@
>   *
>   * Rani Assaf <rani@magic.metawire.com> 980929:	resolve addresses
>   * Kunihiro Ishiguro <kunihiro@zebra.org> 001102: rtnh_ifindex was n=
ot initialized
> + * Gilad Ben-Yossef <gilad@codefidence.com> 091006: Add hoplimit opt=
ion parsing=20
> + * and correct usage

Well, git/web history is much better than this, you dont need to add th=
is comment.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

patch should be sent to iproute2 maintainer, Stephen Hemminger <shemmin=
ger@vyatta.com>

He might be too busy to catch netdev mails these days, I dont know :)

Thanks
