From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 27 Apr 2011 14:04:18 +0200
Message-ID: <1303905858.3166.41.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <EDC0E76513226749BFBC9C3FB031318F016B4125A4@orsmsx508.amr.corp.intel.com>
	 <201104271346.34431.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201104271346.34431.maxi@daemonizer.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 avril 2011 =C3=A0 13:46 +0200, Maximilian Engelhardt a =C3=
=A9crit :

> Hello Carolyn,
>=20
> Thanks for your response.
>=20
> I have opened a issue at
> https://sourceforge.net/tracker/?func=3Ddetail&aid=3D3293703&group_id=
=3D42302&atid=3D447449
> and also posted all information there.
>=20
>=20
> Please not that yesterday I updated the kernel, so I'm now running 2.=
6.38.4.
> Eric Dumazet mentioned on the LKML that this might be a memory corrup=
tion that=20
> my be solved with kernel 2.6.38.
>=20

Hmm, I suggested to use slub_nomerge to make sure inetpeer kmemcache is
not shared with another (possibly mem corruptor) layer.

Please note we were not able to track the bug in 2.6.37 kernels.

> I'll report if the crash happens again, but it might take some times =
as in the=20
> past it happened within the interval of weeks to month.
>=20

Thanks
