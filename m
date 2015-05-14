From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 353/365]
 drivers/net/ethernet/emulex/benet/be_main.c:5473:9: sparse: symbol
 'be_hwmon_show_temp' was not declared. Should it be static?
Date: Fri, 15 May 2015 03:02:34 +0800
Message-ID: <201505150315.NZBccr7Q%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>,
	Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51110 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933823AbbENTD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 15:03:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   b55b10bebb86a436bebd5c754f80076ad51f4068
commit: 29e9122b3ab2aa7160e54c2bbea242b99588325c [353/365] be2net: Export board temperature using hwmon-sysfs interface.
reproduce:
  # apt-get install sparse
  git checkout 29e9122b3ab2aa7160e54c2bbea242b99588325c
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   drivers/net/ethernet/emulex/benet/be_main.c:1266:29: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/emulex/benet/be_main.c:1266:29:    expected unsigned short [unsigned] [short] <noident>
   drivers/net/ethernet/emulex/benet/be_main.c:1266:29:    got restricted __le16 [usertype] <noident>
   drivers/net/ethernet/emulex/benet/be_main.c:2182:32: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/emulex/benet/be_main.c:2182:32:    expected unsigned int [unsigned] [usertype] fragpa_lo
   drivers/net/ethernet/emulex/benet/be_main.c:2182:32:    got restricted __le32 [usertype] <noident>
   drivers/net/ethernet/emulex/benet/be_main.c:2183:32: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/emulex/benet/be_main.c:2183:32:    expected unsigned int [unsigned] [usertype] fragpa_hi
   drivers/net/ethernet/emulex/benet/be_main.c:2183:32:    got restricted __le32 [usertype] <noident>
   drivers/net/ethernet/emulex/benet/be_main.c:4318:36: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4320:36: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4531:24: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4532:26: sparse: cast to restricted __le16
   drivers/net/ethernet/emulex/benet/be_main.c:4602:25: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4603:30: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4604:30: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4605:30: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4831:20: sparse: cast to restricted __le32
   drivers/net/ethernet/emulex/benet/be_main.c:4837:21: sparse: cast to restricted __le32
>> drivers/net/ethernet/emulex/benet/be_main.c:5473:9: sparse: symbol 'be_hwmon_show_temp' was not declared. Should it be static?
   drivers/net/ethernet/emulex/benet/be_main.c:4785:24: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
