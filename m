From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net patch 0/2] bnx2x: Correct bnx2x operation with netpoll
Date: Mon, 27 Aug 2012 16:26:18 +0300
Message-ID: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4066 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153Ab2H0KS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 06:18:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
This patch series corrects bnx2x operation with netpoll:
The first patch is to move the netif_napi_add to the open call to avoid napi
objects that are added but may not be later enabled.
The second patch corrects the poll_bnx2x function itself to also work with
MSI-X.

Please consider applying this patch series to net.

Thanks,
Merav
