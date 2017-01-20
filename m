From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v5 2/2] net: dsa: mv88e6xxx: Add support for ethernet
 switch 88E6341 (fwd)
Date: Fri, 20 Jan 2017 12:43:36 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1701201242320.3339@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>, kbuild-all@01.org
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mv88e6xxx_6341_family is checked twice, on line 2606 and 2607.

julia

---------- Forwarded message ----------
Date: Fri, 20 Jan 2017 19:38:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v5 2/2] net: dsa: mv88e6xxx: Add support for ethernet switch
     88E6341

In-Reply-To: <20170119214934.27442-3-gregory.clement@free-electrons.com>

Hi Gregory,

[auto build test WARNING on net-next/master]
[also build test WARNING on next-20170120]
[cannot apply to v4.10-rc4]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Gregory-CLEMENT/Add-support-for-the-ethernet-switch-on-the-ESPRESSObin/20170120-180348
:::::: branch date: 2 hours ago
:::::: commit date: 2 hours ago

>> drivers/net/dsa/mv88e6xxx/chip.c:2606:36-63: duplicated argument to && or ||

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout c618c22093235e96adf0c6f39497eeed083a60cf
vim +2606 drivers/net/dsa/mv88e6xxx/chip.c

0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2590  	if (err)
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2591  		return err;
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2592
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2593  	/* Egress rate control 2: disable egress rate control. */
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2594  	err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL_2, 0x0000);
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2595  	if (err)
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2596  		return err;
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2597
b35d322a1 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-12-03  2598  	if (chip->info->ops->port_pause_config) {
b35d322a1 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-12-03  2599  		err = chip->info->ops->port_pause_config(chip, port);
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2600  		if (err)
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2601  			return err;
b35d322a1 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-12-03  2602  	}
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2603
b35d322a1 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-12-03  2604  	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
b35d322a1 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-12-03  2605  	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
c618c2209 drivers/net/dsa/mv88e6xxx/chip.c Gregory CLEMENT 2017-01-19 @2606  	    mv88e6xxx_6320_family(chip) || mv88e6xxx_6341_family(chip) ||
c618c2209 drivers/net/dsa/mv88e6xxx/chip.c Gregory CLEMENT 2017-01-19  2607  	    mv88e6xxx_6341_family(chip)) {
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2608  		/* Port ATU control: disable limiting the number of
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2609  		 * address database entries that this port is allowed
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2610  		 * to use.
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2611  		 */
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2612  		err = mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL,
0e7b99257 drivers/net/dsa/mv88e6xxx/chip.c Andrew Lunn     2016-09-21  2613  					   0x0000);
54d792f25 drivers/net/dsa/mv88e6xxx.c      Andrew Lunn     2015-05-06  2614  		/* Priority Override: disable DA, SA and VTU priority

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
