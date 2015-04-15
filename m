From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/6] net: hip04: fix some problem for hip04 drivers
Date: Wed, 15 Apr 2015 20:30:02 +0800
Message-ID: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov@cogentembedded.com>,
	<linux-arm-kernel@lists.infradead.org>, <eric.dumazet@gmail.com>,
	<zhangfei.gao@linaro.org>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux@arm.linux.org.uk>
To: <arnd@arndb.de>, <davem@davemloft.net>, <grant.likely@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:5807 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbbDOMaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 08:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patches series was used to fix the issues of the hip04 driver, and added
some optimizations according to some good suggestion. 

Thanks.

Ding Tianhong (6):
  net: hip04: Set more appropriate value for tx coalesce num
  net: hip04: use the big endian for tx and rx desc
  net: hip04: Solve the problem of the skb memory allocation failure
  net: hip04: Don't free the tx skb when the buffer is not ready for
    xmit
  net: hip04: remove the unnecessary check
  net: hip04: add ratelimit for rx/tx drops skb

 drivers/net/ethernet/hisilicon/hip04_eth.c | 109 ++++++++++++++++++++---------
 1 file changed, 76 insertions(+), 33 deletions(-)

-- 
1.8.0
