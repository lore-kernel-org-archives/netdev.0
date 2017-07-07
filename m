From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Fri, 7 Jul 2017 07:03:01 +0000
Message-ID: <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "dev@g0hl1n.net" <dev@g0hl1n.net>, Andrew Lunn <andrew@lunn.ch>
To: Richard Leitner <richard.leitner@skidata.com>,
        "robh+dt@kernel.org" <robh+dt@kernel.org>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Leitner <richard.leitner@skidata.com> Sent: Friday, July 07, =
2017 1:51 PM
>> Since it is common issue so long as using the PHY, can you move it into =
smsc
>phy driver like in .smsc_phy_reset() function ?
>> And get the reset pin from phy dts node.
>
>Some more points that come into my mind:
>  - The smsc_phy_reset function is registered as "soft_reset". Would it be=
 OK to
>use nRST in it?

It is not reasonable.

>  - Would it be OK to call the phy_init_hw function from within the
>smsc_phy_reset?

No, phy_init_hw() already call .drv->soft_reset().

>  - IMHO I'd have to move the reset gpio binding inside the phy node then.=
 Isn't
>that a pretty big change doing that for all PHYs/FECs? Would it be "worth"=
 it?
>
To make the change to be common, there have big change for phy driver.
Maybe somebody can give one good suggestion/solution for it.

Andy
