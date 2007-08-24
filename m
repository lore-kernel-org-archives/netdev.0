From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge updates for 2.6.23
Date: Fri, 24 Aug 2007 08:56:03 +0200
Message-ID: <46CE8103.10109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1969 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757588AbXHXGyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 02:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Now that Greg pushed my fix to expose pcie_get_readrq() prototype in
linux/pci.h, I am resending my rework of Peter Oruba's patch to use
pcie_get/set_readrq() in myri10ge. Please apply for 2.6.23.

1. use pcie_get/set_readrq
2. update driver version to 1.3.2-1.269



Also, we noticed that packet forwarding is faster on our hardware when
receiving in linear skb instead of pages (about 10Gb/s vs. 7), so we are
thinking of submitting a Kconfig option to switch to the old linear skb
RX code. Would this be acceptable?

Thanks,
Brice

