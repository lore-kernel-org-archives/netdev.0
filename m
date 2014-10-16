From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin
 Ethernet
Date: Thu, 16 Oct 2014 11:53:23 +0200
Message-ID: <20141016095323.GA1061@kwain>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Antoine =?iso-8859-1?Q?T=E9nart?=
	<antoine.tenart@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

On Thu, Oct 09, 2014 at 02:38:58PM +0200, Sebastian Hesselbarth wrote:
> This patch series deals with a removing a IP feature that can be foun=
d
> on all currently supported Marvell Ethernet IP (pxa168_eth, mv643xx_e=
th,
> mvneta). The MAC IP allows to automatically perform PHY auto-negotiat=
ion
> without software interaction.
>=20
> However, this feature (a) fundamentally clashes with the way libphy w=
orks
> and (b) is unable to deal with quirky PHYs that require special treat=
ment.
> In this series, pxa168_eth driver is rewritten to completely disable =
that
> feature and properly deal with libphy provided PHYs. The other two dr=
ivers
> are suspect to future patch sets, also removing the code related with=
 it.
>=20
> Currently, the patches are based on next-20141009 and will be resent =
once
> v3.18-rc1 drops. This is a Request-For-Test on both BG2Q and MMP/gplu=
g as

I tested the series on a BG2Q, it worked well.

Antoine

> these are the current users of pxa168_eth. A branch with this patches=
 on
> top of next-20141009 can be found at
>=20
> git://git.infradead.org/users/hesselba/linux-berlin.git devel/bg2-bg2=
cd-eth-v1
>=20
> It would be great to get a Tested-byfrom MMP guys on gplug - if they
> have that board somewhere. Also, BG2Q (Antoine) needs a phy-connectio=
n-type
> property. My guess is that, if it is using internal PHY, it is "mii",=
 too.

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
