From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v5 1/2] net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for
 PHY addr >= num_of_ports
Date: Thu, 19 Jan 2017 17:13:12 -0500
Message-ID: <871svylmvb.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
 <20170119214934.27442-2-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Jason Cooper <jason@lakedaemon.net>, Joe Zhou <shjzhou@marvell.com>,
 Jon Pannell <jpannell@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Kostya Porotchkin <kostap@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Wilson Ding <dingwei@marvell.com>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170119214934.27442-2-gregory.clement@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> From: Romain Perier <romain.perier@free-electrons.com>
>
> Some Marvell ethernet switches have internal ethernet transceivers with
> hardcoded phy addresses. These addresses can be greater than the number
> of ports or its value might be different than the associated port number.
> This is for example the case for MV88E6341 that has 6 ports and internal
> Port 1 to Port4 PHYs mapped at SMI addresses from 0x11 to 0x14.

Isn't there an hardware table used to map the PHY addresses on such chip?

> This commits fixes the issue by removing the condition in MDIO callbacks.
>
> Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

The patch is anyway still valid:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
