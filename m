From: Brandon Streiff <brandon.streiff@ni.com>
Subject: RE: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Fri, 29 Sep 2017 15:28:02 +0000
Message-ID: <CO2PR04MB218421921CC649BC026F34669F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
 <20170928165643.GB14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928165643.GB14940@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, September 28, 2017 11:57 AM
>=20
> It is the MAC which is doing the time stamping, not they PHY?
> So why NETWORK_PHY_TIMESTAMPING?

NETWORK_PHY_TIMESTAMPING implies NET_PTP_CLASSIFY (which I do use) and net/=
core/timestamping.c (which I didn't). It probably makes more sense to just =
depend on NET_PTP_CLASSIFY directly.

-- brandon
