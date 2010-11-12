From: David Miller <davem@davemloft.net>
Subject: enic build warnings
Date: Fri, 12 Nov 2010 12:40:31 -0800 (PST)
Message-ID: <20101112.124031.245404157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roprabhu@cisco.com, dwang2@cisco.com, netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932828Ab0KLUkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:40:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please fix these warnings, you cannot pass the address of
a "u64" object where a "dma_addr_t" is expected:

drivers/net/enic/enic_main.c: In function 'enic_set_rsskey':
drivers/net/enic/enic_main.c:2056:16: warning: passing argument 3 of 'pci_alloc_consistent' from incompatible pointer type
include/asm-generic/pci-dma-compat.h:16:1: note: expected 'dma_addr_t *' but argument is of type 'u64 *'
drivers/net/enic/enic_main.c: In function 'enic_set_rsscpu':
drivers/net/enic/enic_main.c:2082:16: warning: passing argument 3 of 'pci_alloc_consistent' from incompatible pointer type
include/asm-generic/pci-dma-compat.h:16:1: note: expected 'dma_addr_t *' but argument is of type 'u64 *'

Thanks.
