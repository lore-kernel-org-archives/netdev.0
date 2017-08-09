From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 05/12] Documentation: net: phy: Add phy-is-internal binding
Date: Wed, 09 Aug 2017 15:47:34 -0700
Message-ID: <778B0470-8ABD-46AD-A63D-F0CF4911C800@gmail.com>
References: <1502280475-736-1-git-send-email-david.wu@rock-chips.com> <1502280630-2254-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>, davem@davemloft.net,
        heiko@sntech.de, andrew@lunn.ch, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502280630-2254-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On August 9, 2017 5:10:30 AM PDT, David Wu <david=2Ewu@rock-chips=2Ecom> wr=
ote:
>Add the documentation for internal phy=2E A boolean property
>indicates that a internal phy will be used=2E
>
>Signed-off-by: David Wu <david=2Ewu@rock-chips=2Ecom>
>---
> Documentation/devicetree/bindings/net/phy=2Etxt | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/Documentation/devicetree/bindings/net/phy=2Etxt
>b/Documentation/devicetree/bindings/net/phy=2Etxt
>index b558576=2E=2E942c892 100644
>--- a/Documentation/devicetree/bindings/net/phy=2Etxt
>+++ b/Documentation/devicetree/bindings/net/phy=2Etxt
>@@ -52,6 +52,9 @@ Optional Properties:
>   Mark the corresponding energy efficient ethernet mode as broken and
>   request the ethernet to stop advertising it=2E
>=20
>+- phy-is-internal: If set, indicates that phy will connect to the MAC
>as a
>+  internal phy=2E

Something along the lines of:

If set, indicates that the PHY is integrated into the same physical packag=
e as the Ethernet MAC=2E

Please always capitalize PHY=2E


--=20
Florian
