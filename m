From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: linux-next: manual merge of the arm-soc tree with the net-next
 tree
Date: Tue, 27 Nov 2012 16:52:28 +0530
Message-ID: <50B4A274.5070601@ti.com>
References: <20121126204546.ef1f1b55e903eda38a61d5d1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	AnilKumar Ch <anilkumar@ti.com>,
	Benoit Cousson <b-cousson@ti.com>,
	Jon Hunter <jon-hunter@ti.com>, Afzal Mohammed <afzal@ti.com>,
	"Philip, Avinash" <avinashphilip@ti.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20121126204546.ef1f1b55e903eda38a61d5d1@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2012 3:15 PM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the arm-soc tree got a conflict in
> arch/arm/boot/dts/am33xx.dtsi between commit 1a39a65cba08 ("arm/dts:
> am33xx: Add CPSW and MDIO module nodes for AM33XX") from the net-next
> tree and commits 059b185d5345 ("ARM: dts: AM33XX: Add D_CAN device tree
> data") and 4c94ac29b5c1 ("ARM: dts: OMAP: Move interrupt-parent to the
> root node to avoid duplication") (and a few others that added more later
> nodes) from the arm-soc tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>
Stephen Rothwell

The fix is correct and I have tested CPSW from linux-next.

Regards
Mugunthan V N
