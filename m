From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 0/3] ehea fixes for 3.4
Date: Tue, 17 Apr 2012 11:41:52 -0300
Message-ID: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:35042 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab2DQOmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 10:42:11 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 17 Apr 2012 11:42:09 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 26F5A1DC004B
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 11:42:04 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3HEfox529819142
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 11:41:50 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3HCg0BT025039
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 09:42:00 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave.

These are bug fixes for 3.4, including a crash and bad behaviour with
promiscuous and multicast.

Thanks.
Cascardo.

Thadeu Lima de Souza Cascardo (3):
  ehea: fix allmulticast support
  ehea: fix promiscuous mode
  ehea: do not dereference possible NULL port

 drivers/net/ethernet/ibm/ehea/ehea_main.c |   43 +++++++++++++++-------------
 drivers/net/ethernet/ibm/ehea/ehea_phyp.h |    2 +-
 2 files changed, 24 insertions(+), 21 deletions(-)

-- 
1.7.4.4
