From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] liquidio: 'imply' ptp instead of 'select'
Date: Sat, 3 Dec 2016 09:23:40 +0800
Message-ID: <201612030941.E0AwlX5M%fengguang.wu@intel.com>
References: <20161202230451.1639318-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        David Daney <david.daney@cavium.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Sunil Goutham <sgoutham@cavium.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161202230451.1639318-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Arnd-Bergmann/liquidio-imply-ptp-instead-of-select/20161203-084019
config: x86_64-allmodconfig
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        make ARCH=x86_64  allmodconfig
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

>> drivers/net/ethernet/cavium/Kconfig:81: syntax error
>> drivers/net/ethernet/cavium/Kconfig:80: unknown option "imply"
   make[2]: *** [allmodconfig] Error 1
   make[1]: *** [allmodconfig] Error 2
   make: *** [sub-make] Error 2
--
>> drivers/net/ethernet/cavium/Kconfig:81: syntax error
>> drivers/net/ethernet/cavium/Kconfig:80: unknown option "imply"
   make[2]: *** [oldconfig] Error 1
   make[1]: *** [oldconfig] Error 2
   make: *** [sub-make] Error 2
--
>> drivers/net/ethernet/cavium/Kconfig:81: syntax error
>> drivers/net/ethernet/cavium/Kconfig:80: unknown option "imply"
   make[2]: *** [olddefconfig] Error 1
   make[2]: Target 'oldnoconfig' not remade because of errors.
   make[1]: *** [oldnoconfig] Error 2
   make: *** [sub-make] Error 2

vim +81 drivers/net/ethernet/cavium/Kconfig

d07a147f David Daney     2016-03-14  74  	  port on Cavium Networks' Octeon CN57XX, CN56XX, CN55XX,
d07a147f David Daney     2016-03-14  75  	  CN54XX, CN52XX, and CN6XXX chips.
d07a147f David Daney     2016-03-14  76  
111fc64a Raghu Vatsavayi 2016-11-28  77  config LIQUIDIO_VF
111fc64a Raghu Vatsavayi 2016-11-28  78  	tristate "Cavium LiquidIO VF support"
111fc64a Raghu Vatsavayi 2016-11-28  79  	depends on 64BIT && PCI_MSI
2d6e65ca Arnd Bergmann   2016-12-03 @80  	imply PTP_1588_CLOCK
111fc64a Raghu Vatsavayi 2016-11-28 @81  	---help---
111fc64a Raghu Vatsavayi 2016-11-28  82  	  This driver supports Cavium LiquidIO Intelligent Server Adapter
111fc64a Raghu Vatsavayi 2016-11-28  83  	  based on CN23XX chips.
111fc64a Raghu Vatsavayi 2016-11-28  84  

:::::: The code at line 81 was first introduced by commit
:::::: 111fc64a237f231bc2d3187bdf8358eb7966e6a9 liquidio CN23XX: VF registration

:::::: TO: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
