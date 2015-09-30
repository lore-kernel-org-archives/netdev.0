From: kbuild test robot <lkp@intel.com>
Subject: Re: [RFC v3 net-next 09/10] qed: Add statistics support
Date: Wed, 30 Sep 2015 22:18:00 +0800
Message-ID: <201509302225.Cv9Emifk%fengguang.wu@intel.com>
References: <1443618217-18069-10-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com, Manish Chopra <Manish.Chopra@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:58147 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbbI3OTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:19:22 -0400
Content-Disposition: inline
In-Reply-To: <1443618217-18069-10-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Manish,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   drivers/net/ethernet/qlogic/qed/qed_dev.c:374:16: sparse: incorrect type in argument 4 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_dev.c:374:16:    expected unsigned int [unsigned] [usertype] val
   drivers/net/ethernet/qlogic/qed/qed_dev.c:374:16:    got restricted __le32 [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_dev.c:1582:25: sparse: cast from restricted __le32
>> drivers/net/ethernet/qlogic/qed/qed_dev.c:1582:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1584:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1584:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1586:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1586:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1588:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1588:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1590:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1590:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1592:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1592:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1594:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1594:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1597:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1597:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1599:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1599:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1601:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1601:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1603:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1603:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1605:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1605:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1607:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1607:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1610:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1610:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1612:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1612:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1615:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1615:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1617:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1617:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1619:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1619:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1621:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1621:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1623:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1623:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1625:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1625:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1627:25: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_dev.c:1627:25: sparse: restricted __le32 degrades to integer

vim +1582 drivers/net/ethernet/qlogic/qed/qed_dev.c

  1566	
  1567			memset(&tstats, 0, sizeof(tstats));
  1568			qed_memcpy_from(p_hwfn, p_ptt, &tstats,
  1569					p_hwfn->storm_stats.tstats.address,
  1570					p_hwfn->storm_stats.tstats.len);
  1571	
  1572			memset(&port_stats, 0, sizeof(port_stats));
  1573	
  1574			if (p_hwfn->mcp_info)
  1575				qed_memcpy_from(p_hwfn, p_ptt, &port_stats,
  1576						p_hwfn->mcp_info->port_addr +
  1577						offsetof(struct public_port, stats),
  1578						sizeof(port_stats));
  1579			qed_ptt_release(p_hwfn, p_ptt);
  1580	
  1581			stats->no_buff_discards +=
> 1582				HILO_64_REGPAIR(mstats.no_buff_discard);
  1583			stats->packet_too_big_discard +=
  1584				HILO_64_REGPAIR(mstats.packet_too_big_discard);
  1585			stats->ttl0_discard +=
  1586				HILO_64_REGPAIR(mstats.ttl0_discard);
  1587			stats->tpa_coalesced_pkts +=
  1588				HILO_64_REGPAIR(mstats.tpa_coalesced_pkts);
  1589			stats->tpa_coalesced_events +=
  1590				HILO_64_REGPAIR(mstats.tpa_coalesced_events);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
