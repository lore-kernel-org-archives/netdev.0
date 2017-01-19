From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v5 2/2] net: dsa: mv88e6xxx: Add support for ethernet
 switch 88E6341
Date: Thu, 19 Jan 2017 17:26:03 -0500
Message-ID: <87y3y6k7pg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
 <20170119214934.27442-3-gregory.clement@free-electrons.com>
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
In-Reply-To: <20170119214934.27442-3-gregory.clement@free-electrons.com>
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

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> +static bool mv88e6xxx_6341_family(struct mv88e6xxx_chip *chip)
> +{
> +	return chip->info->family == MV88E6XXX_FAMILY_6341;
> +}

I don't want to see these erronous family checks anymore, but I cannot
blame you for adding it since not all the code is moved to ops yet ;)

>  	MV88E6XXX_FAMILY_6165,	/* 6123 6161 6165 */
>  	MV88E6XXX_FAMILY_6185,	/* 6108 6121 6122 6131 6152 6155 6182 6185 */
>  	MV88E6XXX_FAMILY_6320,	/* 6320 6321 */
> +	MV88E6XXX_FAMILY_6341,	/* 6141 6341 */

Maybe I missed it, Andrew, can you confirm that 6341 is a proper Marvell
family of switch chips?

>  	MV88E6XXX_FAMILY_6351,	/* 6171 6175 6350 6351 */
>  	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
>  	MV88E6XXX_FAMILY_6390,  /* 6190 6190X 6191 6290 6390 6390X */

Otherwise the patch looks good.

Thanks,

        Vivien
