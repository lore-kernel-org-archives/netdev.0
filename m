From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin
 Ethernet
Date: Mon, 20 Oct 2014 17:10:28 +0200
Message-ID: <20141020151028.GA17117@kwain>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20141016095323.GA1061@kwain>
 <54451E3F.1030700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54451E3F.1030700@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian,

On Mon, Oct 20, 2014 at 04:37:51PM +0200, Sebastian Hesselbarth wrote:
> On 16.10.2014 11:53, Antoine Tenart wrote:
> >On Thu, Oct 09, 2014 at 02:38:58PM +0200, Sebastian Hesselbarth wrot=
e:
> >>This patch series deals with a removing a IP feature that can be fo=
und
> >>on all currently supported Marvell Ethernet IP (pxa168_eth, mv643xx=
_eth,
> >>mvneta). The MAC IP allows to automatically perform PHY auto-negoti=
ation
> >>without software interaction.
> >>
> >>However, this feature (a) fundamentally clashes with the way libphy=
 works
> >>and (b) is unable to deal with quirky PHYs that require special tre=
atment.
> >>In this series, pxa168_eth driver is rewritten to completely disabl=
e that
> >>feature and properly deal with libphy provided PHYs. The other two =
drivers
> >>are suspect to future patch sets, also removing the code related wi=
th it.
> >>
> >>Currently, the patches are based on next-20141009 and will be resen=
t once
> >>v3.18-rc1 drops. This is a Request-For-Test on both BG2Q and MMP/gp=
lug as
> >
> >I tested the series on a BG2Q, it worked well.
>=20
> Thanks for testing! I assume you have added a phy-connection-type
> property to BG2Q's ethernet node?

Yes, I added the following property to the ethernet-phy node:

	phy-connection-type =3D "mii";

=46eel free to add this to your series, or I can also send a patch.


Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
