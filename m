From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/9] net: dsa: mv88e6xxx: extract device mapping
Date: Thu, 14 Jul 2016 18:24:14 -0400
Message-ID: <871t2vvoxd.fsf@ketchup.mtl.sfl>
References: <201607072220.IpnBB4FC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201607072220.IpnBB4FC%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David, all,

kbuild test robot <lkp@intel.com> writes:

> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Vivien-Didelot/net-dsa-mv88e6xxx-STP-and-Global-2-cleanup/20160707-210537
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> All errors (new ones prefixed by >>):
>
>    drivers/net/dsa/mv88e6xxx/chip.c: In function 'mv88e6xxx_g2_set_device_mapping':
>>> drivers/net/dsa/mv88e6xxx/chip.c:3116:16: error: 'DSA_RTABLE_NONE' undeclared (first use in this function)
>        if (port == DSA_RTABLE_NONE)
>                    ^~~~~~~~~~~~~~~
>    drivers/net/dsa/mv88e6xxx/chip.c:3116:16: note: each undeclared identifier is reported only once for each function it appears in

Note that this error is no longer valid since the merged commit
d390238c4fba ("net: dsa: initialize the routing table") introduces the
DSA_RTABLE_NONE symbol.

Thanks,

        Vivien
