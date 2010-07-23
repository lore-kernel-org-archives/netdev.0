From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 08:28:43 +0200
Message-ID: <1279866523.2482.78.camel@edumazet-laptop>
References: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>
	 <alpine.LSU.2.01.1007230818260.815@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007230818260.815@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 juillet 2010 =C3=A0 08:20 +0200, Jan Engelhardt a =C3=A9=
crit :
> On Friday 2010-07-23 06:54, Changli Gao wrote:
>=20
> >This patch should be applied after my another patch:
> >http://patchwork.ozlabs.org/patch/59729/
> >
> >xt_quota: don't copy quota back to userspace
> >
> >In nowadays, table entries are per-cpu variables, so it don't make a=
ny=20
> >sense to copy quota back to one of the variable instances. To keep=20
> >things simple, this patch undo the copy.
>=20
> I object. This line is on purpose, to give at least a chance of=20
> reporting back a more-or-less believable value. Without copying
> the value back, users have moaned about the counter not decreasing
> _at all_.

Maybe, but current situation is buggy.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
