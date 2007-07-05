From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 0/2] Convert skb to use scatterlist
Date: Thu, 05 Jul 2007 16:14:12 -0700
Message-ID: <20070705231412.021359760@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41619 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758387AbXGEXRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:17:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This topic came up at first Netconf. This patch changes skbuff
to use scatterlist. Why? Devices can than use the pci_dma_sg
routines to map the fraglist in one operation. This allows
for better error handling (less unwinding), and some IOMMU's
(PPC?) can be smarter.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

