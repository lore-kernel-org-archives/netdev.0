From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 0/4] qlcnic: Bug fixes.
Date: Mon, 22 Sep 2014 05:51:49 -0400
Message-ID: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:25569 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753198AbaIVKZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 06:25:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains following bug fixes:

* Fixes related to ethtool statistics.
* Fix for flash read related API.

Please apply this series to 'net'.

Thanks,
Manish

Manish Chopra (3):
  qlcnic: Fix memory corruption while reading stats using ethtool.
  qlcnic: Remove __QLCNIC_DEV_UP bit check to read TX queues
    statistics.
  qlcnic: Fix ordering of stats in stats buffer.

Sony Chacko (1):
  qlcnic: Use qlcnic_83xx_flash_read32() API instead of lockless
    version of the API.

 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    5 ++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   10 +++++-----
 2 files changed, 7 insertions(+), 8 deletions(-)
