From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 1/4] net:hns: Add support of Hip06 SoC to the
 Hislicon Network Subsystem
Date: Tue, 20 Oct 2015 23:54:56 +0800
Message-ID: <201510202306.WYUMdngA%fengguang.wu@intel.com>
References: <1445353278-130498-2-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	paul.gortmaker@windriver.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com,
	arnd@arndb.de, liguozhu@hisilicon.com, yisen.zhuang@huawei.com,
	dingtianhong@huawei.com, zhangfei.gao@linaro.org,
	huangdaode@hisilicon.com, kenneth-lee-2012@foxmail.com,
	salil.mehta@huawei.com, mehta.salil.lnk@gmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linuxarm@huawei.com, yankejian <yankejian@huawei.com>,
	lipeng <lipeng321@huawei.com>
To: Salil <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445353278-130498-2-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Salil,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Salil/net-hns-Add-support-of-Hip06-SoC-to-the-Hislicon-Network-Subsystem/20151020-225151
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:110:20: sparse: symbol 'hns_ae_get_handle' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:297:6: sparse: symbol 'hns_ae_stop' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:328:6: sparse: symbol 'hns_ae_toggle_ring_irq' was not declared. Should it be static?
>> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:340:6: sparse: symbol 'hns_aev2_toggle_ring_irq' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:500:6: sparse: symbol 'hns_ae_update_stats' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:583:6: sparse: symbol 'hns_ae_get_stats' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:615:6: sparse: symbol 'hns_ae_get_strings' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:647:5: sparse: symbol 'hns_ae_get_sset_count' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:685:6: sparse: symbol 'hns_ae_update_led_status' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:696:5: sparse: symbol 'hns_ae_cpld_set_led_id' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:708:6: sparse: symbol 'hns_ae_get_regs' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:735:5: sparse: symbol 'hns_ae_get_regs_len' was not declared. Should it be static?
--
   drivers/net/ethernet/hisilicon/hns/hnae.h:601:31: sparse: cast to restricted __le64
   drivers/net/ethernet/hisilicon/hns/hnae.h:594:31: sparse: cast to restricted __le64
   drivers/net/ethernet/hisilicon/hns/hns_enet.c:962:6: sparse: symbol 'hns_nic_update_stats' was not declared. Should it be static?
>> drivers/net/ethernet/hisilicon/hns/hns_enet.c:998:6: sparse: symbol 'hns_set_irq_affinity' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_enet.c:1260:6: sparse: symbol 'hns_nic_poll_controller' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_enet.c:1331:6: sparse: symbol 'hns_set_multicast_list' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_enet.c:1349:6: sparse: symbol 'hns_nic_set_rx_mode' was not declared. Should it be static?
   drivers/net/ethernet/hisilicon/hns/hns_enet.c:1364:26: sparse: symbol 'hns_nic_get_stats64' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
