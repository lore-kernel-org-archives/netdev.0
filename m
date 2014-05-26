From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] macvlan: fix the problem when mac address changes for passthru mode
Date: Mon, 26 May 2014 20:10:31 +0800
Message-ID: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:32860 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaEZMLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 08:11:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (2):
  macvlan: don't change macvlan address alone for passthru mode
  macvlan: propagate lowerdev mac address changes for passthru mode

 drivers/net/macvlan.c | 40 +++++++++++++++++++++++++++++++---------
 1 file changed, 31 insertions(+), 9 deletions(-)

-- 
1.8.0
