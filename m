From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Tue, 26 Apr 2011 14:25:22 +0900
Message-ID: <1303795522.6010.5.camel@nausicaa>
References: <1303461461.3134.15.camel@edumazet-laptop>
	 <4DB61C2C.7060508@netfilter.org> <1303781180.2874.13.camel@nausicaa>
	 <20110425.221744.226775617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110425.221744.226775617.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-04-25 at 22:17 -0700, David Miller wrote:
> From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> Date: Tue, 26 Apr 2011 10:26:20 +0900
>=20
> > On Tue, 2011-04-26 at 03:13 +0200, Pablo Neira Ayuso wrote:
> >> On 22/04/11 10:37, Eric Dumazet wrote:
> >> > Le vendredi 22 avril 2011 =C3=A0 17:11 +0900, Fernando Luis Vazq=
uez Cao a
> >> > =C3=A9crit :
> >> >=20
> >> >> Thank you!
> >> >>
> >> >> Should we send these two patches to -stable too?
> >> >=20
> >> > David takes care of stable submissions for netdev stuff, thanks.
> >>=20
> >> If the patch follows the netfilter path, we'll take care of sendin=
g
> >> stable submissions.
> >=20
> > David, will you take care of these two patches or should they go th=
rough
> > the netfilter tree?
>=20
> Netfilter, as usual.

Thank you for the clarification. I really appreciate it.

Pablo, could you pull in the two patches below? They have already been
acked by Eric. It would be great it we could get them merged for the
next -rc and stable releases.

[PATCH] netfilter/IPv6: fix DSCP mangle code
[PATCH] netfilter/IPv6: initialize TOS field in REJECT target module

- Fernando

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
