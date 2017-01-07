From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 12/12] net: ethernet: aquantia: Receive side scaling
Date: Sat, 7 Jan 2017 17:48:59 +0800
Message-ID: <201701071732.BdxDZUjn%fengguang.wu@intel.com>
References: <22b9276ab1020a75c13aa2714922434886446d69.1483689029.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        David VomLehn <vomlehn@texas.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:27642 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752161AbdAGJtj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 04:49:39 -0500
Content-Disposition: inline
In-Reply-To: <22b9276ab1020a75c13aa2714922434886446d69.1483689029.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.10-rc2 next-20170106]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Loktionov/net-ethernet-aquantia-Add-AQtion-2-5-5-GB-NIC-driver/20170107-100651
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
--
   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
--
   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
--
   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition
>> drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h:44:28: sparse: marked inline, but without a definition

vim +44 drivers/net/ethernet/aquantia/hw_atl/../aq_hw_utils.h

96511018 David VomLehn 2017-01-06  28  	unsigned int AQ_HW_WAIT_FOR_i; \
96511018 David VomLehn 2017-01-06  29  	for (AQ_HW_WAIT_FOR_i = _N_; (!(_B_)) && (AQ_HW_WAIT_FOR_i);\
96511018 David VomLehn 2017-01-06  30  	--AQ_HW_WAIT_FOR_i) {\
96511018 David VomLehn 2017-01-06  31  		udelay(_US_); \
96511018 David VomLehn 2017-01-06  32  	} \
96511018 David VomLehn 2017-01-06  33  	if (!AQ_HW_WAIT_FOR_i) {\
96511018 David VomLehn 2017-01-06  34  		err = ETIME; \
96511018 David VomLehn 2017-01-06  35  	} \
96511018 David VomLehn 2017-01-06  36  } while (0)
96511018 David VomLehn 2017-01-06  37  
96511018 David VomLehn 2017-01-06  38  struct aq_hw_s;
96511018 David VomLehn 2017-01-06  39  
96511018 David VomLehn 2017-01-06  40  void aq_hw_write_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
96511018 David VomLehn 2017-01-06  41  			 u32 shift, u32 val);
96511018 David VomLehn 2017-01-06  42  u32 aq_hw_read_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk, u32 shift);
96511018 David VomLehn 2017-01-06  43  u32 aq_hw_read_reg(struct aq_hw_s *hw, u32 reg);
96511018 David VomLehn 2017-01-06 @44  inline void aq_hw_write_reg(struct aq_hw_s *hw, u32 reg, u32 value);
96511018 David VomLehn 2017-01-06  45  int aq_hw_err_from_flags(struct aq_hw_s *hw);
96511018 David VomLehn 2017-01-06  46  
96511018 David VomLehn 2017-01-06  47  #endif /* AQ_HW_UTILS_H */

:::::: The code at line 44 was first introduced by commit
:::::: 9651101834438045cb888ea0bea44cc575b69d03 net: ethernet: aquantia: Hardware interface and utility functions

:::::: TO: David VomLehn <vomlehn@texas.net>
:::::: CC: 0day robot <fengguang.wu@intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
