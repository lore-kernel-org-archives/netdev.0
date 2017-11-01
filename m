From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 0/2] net: dpaa: two minor cleanup
Date: Wed,  1 Nov 2017 21:09:50 +0800
Message-ID: <1509541790-16068-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:56743 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751853AbdKANKg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 09:10:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

original i try to remove duplicate code which clean allocated per-cpu area,
thanks to David S. Miller, there are two build warning as errors.
path 1: fix old code maybe-uninitialized warning.
path 2: remove duplicate code and fix unused var warning.


yuan linyu (2):
  net: dpaa: fix maybe uninitialized var in dpaa_open()
  net: dpaa: remove init which already done in per-cpu allocation

 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

-- 
2.7.4
