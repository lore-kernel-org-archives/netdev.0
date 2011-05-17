From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ping: fix build failure
Date: Tue, 17 May 2011 12:27:04 +0200
Message-ID: <1305628024.2850.51.camel@edumazet-laptop>
References: <20110516151019.be338f1c.sfr@canb.auug.org.au>
	 <20110516123534.5d3a51b9.randy.dunlap@oracle.com>
	 <20110516.153844.1072050131335197211.davem@davemloft.net>
	 <20110517101656.GA28685@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, randy.dunlap@oracle.com,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110517101656.GA28685@albatros>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 mai 2011 =C3=A0 14:16 +0400, Vasiliy Kulikov a =C3=A9crit :
> On Mon, May 16, 2011 at 15:38 -0400, David Miller wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > Date: Mon, 16 May 2011 12:35:34 -0700
> >=20
> > > On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:
> > > when CONFIG_PROC_SYSCTL is not enabled:
> > >=20
> > > ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_gro=
up_range_net'
> >=20
> > Vasiliy, please fix this.
>=20
> I wonder whether there is any way to test such unusual configurations=
?
> Only randconfig or are there any (partly-)automated tools for it?
>=20
>=20
> [PATCH] net: ping: fix build failure
>=20
> If CONFIG_PROC_SYSCTL=3Dn the building process fails:
>=20
>     ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_gro=
up_range_net'
>=20
> Moved inet_get_ping_group_range_net() to ping.c.
>=20
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
