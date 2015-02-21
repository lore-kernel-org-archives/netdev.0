From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sat, 21 Feb 2015 20:26:22 +0100
Message-ID: <20150221192622.GB25687@louise.pinerecords.com>
References: <20150203100816.GA5807@louise.pinerecords.com>
 <20150203104214.GG24751@breakpoint.cc>
 <20150210154536.GB16264@breakpoint.cc>
 <20150221101512.GB17223@louise.pinerecords.com>
 <20150221103104.GA26574@breakpoint.cc>
 <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150221174625.GA29681@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150221174625.GA29681@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Could Tomas try following fix ?
>=20
> In addition -- Tomas, on your affected board -- did you try
> turning off gso/tso?
>=20
> Holger Hoffst=C3=A4tte mentioned on lkml that his affected r8169 nic =
is
> stable with xmit_more+bql after disabling gso/tso on the nic
>=20
> (ethtool -k $dev to display settings, "-K $dev tso off gso off" to
>  disable offloads).

They're always off on this NIC (cannot be turned on).

# ethtool -k eth1| grep segmentation-offload
tcp-segmentation-offload: off
generic-segmentation-offload: off [requested on]
# ethtool -K eth1 gso on tso on
Could not change any device features
# ethtool -k eth1| grep segmentation-offload
tcp-segmentation-offload: off
generic-segmentation-offload: off [requested on]

--=20
Tomas Szepe <szepe@pinerecords.com>
