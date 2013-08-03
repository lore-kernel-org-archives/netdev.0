From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: fix suppressor names and default values
Date: Sat, 3 Aug 2013 20:28:13 +0200
Message-ID: <20130803182813.GP21970@zirkel.wertarbyte.de>
References: <20130803121443.GL21970@zirkel.wertarbyte.de>
 <20130803.103722.780534029060943275.davem@davemloft.net>
 <20130803.104125.609502695540219854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:39731 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208Ab3HCS2O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 14:28:14 -0400
Content-Disposition: inline
In-Reply-To: <20130803.104125.609502695540219854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb David Miller (davem@davemloft.net):

> I had to fix the following obvious typo:
>=20
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 47916b0..2e65413 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -351,7 +351,7 @@ static int fib_nl_newrule(struct sk_buff *skb, st=
ruct nlmsghdr* nlh)
>  	if (tb[FRA_SUPPRESS_IFGROUP])
>  		rule->suppress_ifgroup =3D nla_get_u32(tb[FRA_SUPPRESS_IFGROUP]);
>  	else
> -		rule->suppress_ifgroup -1;
> +		rule->suppress_ifgroup =3D -1;
> =20
>  	if (!tb[FRA_PRIORITY] && ops->default_pref)
>  		rule->pref =3D ops->default_pref(ops);
>=20
> Are you even looking at the build of the code you are submitting?
> Because here the compiler told me:
>=20
> net/core/fib_rules.c: In function =E2=80=98fib_nl_newrule=E2=80=99:
> net/core/fib_rules.c:354:3: warning: statement with no effect [-Wunus=
ed-value]

My apologies, I just checked my tinkering branch where the typo is not =
present;
it must have crept in while squashing together a number of smaller comm=
its
while compiling the patch, perhaps while fixing some whitespace issue (=
empty
line).

The compiler message must have slipped by, I'll try to triple check nex=
t time.

Thank you for the quick fix.

Stefan Tomanek
