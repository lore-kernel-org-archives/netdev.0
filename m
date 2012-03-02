From: Alex Shi <alex.shi@intel.com>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Fri, 02 Mar 2012 10:45:17 +0800
Message-ID: <1330656317.21053.1411.camel@debian>
References: <1329466694.12669.2976.camel@debian>
	 <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120217.133327.1178765872497293871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	tim.c.chen@intel.com, ying.huang@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Tang Feng <feng.tang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120217.133327.1178765872497293871.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-02-17 at 13:33 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 17 Feb 2012 10:50:39 +0100
>=20
> > Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 16:18 +0800, Alex,Shi a =C3=
=A9crit :
> >> The tcp_stream loop back performance has about 10% drop on the
> >> commitment on our core2 2 sockets server. This commit has 2
> >> parents(7505afe28, 5983fe), but both of them have no regression. S=
o
> >> guess the impact just happened when this 2 parents joint. That bey=
ond
> >> our capability to dig it more.
> >>=20
> >> Any ideas?=20
> >=20
> > Most probably the more accurate truesize determination is responsib=
le of
> > this tcp regression, since some prior assumptions might be wrong.
> >=20
> > Want to give more information on the workload ?
> > Is it a 32 or 64 bit kernel ?
>=20
> And let's start CC:'ing netdev too.

Add CC to tang feng, He is working on this issue.=20
