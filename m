From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Mon, 18 Oct 2010 19:52:28 +0200
Message-ID: <1287424348.2359.1.camel@edumazet-laptop>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
	 <20101002112419.248437367@gulag1.americas.sgi.com>
	 <20101005.145032.25126909.davem@davemloft.net>
	 <20101018174339.GC14068@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, w@1wt.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Robin Holt <holt@sgi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101018174339.GC14068@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 18 octobre 2010 =C3=A0 12:43 -0500, Robin Holt a =C3=A9crit :
> On Tue, Oct 05, 2010 at 02:50:32PM -0700, David Miller wrote:
> > From: Robin Holt <holt@sgi.com>
> > Date: Sat, 02 Oct 2010 06:24:06 -0500
> >=20
> > > Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initiali=
zers to prevent integer overflows.
> > >=20
> > > On a 16TB x86_64 machine, sysctl_tcp_mem[2], sysctl_udp_mem[2], a=
nd
> > > sysctl_sctp_mem[2] can integer overflow.  Set limit such that the=
y are
> > > maximized without overflowing.
> > >=20
> > > Signed-off-by: Robin Holt <holt@sgi.com>
> >=20
> > Robin please resubmit this with the SCTP bits included.
>=20
> David,
>=20
> I did not mean to blow you off.  I was not going to resubmit because
> Eric's patch is the preferred direction.  I had been given an indicat=
ion
> that my patch was preferred, but that indicator changed.
>=20

Maybe there is some misunderstanding.

My patch was for net-next kernels (not before 2.6.37), while yours was
applicable to previous kernels.
