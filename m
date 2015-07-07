From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 0/3] rtnl_lock fixes
Date: Tue, 07 Jul 2015 18:53:28 +0300
Message-ID: <559BF5F8.2000500@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44712 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758038AbbGGPye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 11:54:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigation possible reasons of net_todo_list corruption 
on rhel6 based OpenVZ kernel I've found few places not fixed in mainline.

Vasily Averin (3):
  missing rtnl_unlock in i40evf_resume()
  missing rtnl_unlock in igb_sriov_reinit()
  ipmr_free_table() should be called under taken rtnl_lock

 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 +
 drivers/net/ethernet/intel/igb/igb_main.c       | 1 +
 net/ipv6/ip6mr.c                                | 2 ++
 3 files changed, 4 insertions(+)

-- 
1.9.1
