From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 0/2] bnx2x: add support for low latency rx
Date: Tue, 18 Jun 2013 10:42:11 +0300
Message-ID: <1371541333-19225-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2966 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480Ab3FRHm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 03:42:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

This series adds to bnx2x driver capabilities for low latency rx.
It bases on ixgbe driver code and tested with TCP_RR/UDP_RR.
The results show about 50% boost in both scenarious. With second patch
we have additional 5%.

Please, consider applying it to net-next.

Thanks,
Dmitry
