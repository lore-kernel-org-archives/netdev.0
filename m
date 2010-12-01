From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] bonding: clean up netpoll code
Date: Wed, 01 Dec 2010 09:03:32 +0100
Message-ID: <1291190612.2856.481.camel@edumazet-laptop>
References: <20101201075043.5741.29172.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101201075043.5741.29172.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 02:45 -0500, Amerigo Wang a =C3=
=A9crit :
> Against net-next-2.6.
>=20
> This patch unifies the netpoll code in bonding with netpoll code in b=
ridge,
> thanks to Herbert that code is much cleaner now.
>=20
> It also removes the flag IFF_IN_NETPOLL, we don't need it any more si=
nce
> we have netpoll_tx_running() now.
>=20
> It passes my basic testings.

Sorry this NETPOLL patch is frightening...

Could you split it in several parts ?

The removal of IFF_IN_NETPOLL deserves a patch on its own, its not a
cleanup at all, if you ask me.

Thanks
