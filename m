From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 07:24:07 +0100
Message-ID: <1290147847.2489.1.camel@edumazet-laptop>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
	 <1290095020.2781.203.camel@edumazet-laptop>
	 <AANLkTi=w8vvVNYMa5D-_4UDoVJABbvM9CVYjABrVoWPY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=w8vvVNYMa5D-_4UDoVJABbvM9CVYjABrVoWPY@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 19 novembre 2010 =C3=A0 07:36 +0800, Changli Gao a =C3=A9cr=
it :
> On Thu, Nov 18, 2010 at 11:43 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > You consume 16 bytes per counter in the main table, while 4 bytes i=
ndex
> > should be enough on SMP build. Most firewalls I know use two or fou=
r
> > cpus at most.
>=20
> I think we can't change the structure of ipt_entry, as it is exposed
> to userspace as an ABI. Though there is no need to keep the same
> structure in the kernel space, converting is a big work. :)
>=20

We already do that for COMPAT. This is a not a big deal to always use a
converter and make it dependent on userland being 32 or 64 bit.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
