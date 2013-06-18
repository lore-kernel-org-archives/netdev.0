From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 0/2] bnx2x: add support for low latency rx
Date: Wed, 19 Jun 2013 01:36:03 +0300
Message-ID: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4733 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754090Ab3FRWgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 18:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

This series adds to bnx2x driver capabilities for low latency rx.
It bases on ixgbe driver code and tested with TCP_RR/UDP_RR.
The results show about 50% boost in both scenarious. With second patch
we have additional 5%.

Please, consider applying it to net-next.

V1->V2
	* change function prototypes from int to bool (from Eric)
	* do not allow poll when GRO/LRO enabled

Thanks,
Dmitry
