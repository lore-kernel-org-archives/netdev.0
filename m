From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 12 Nov 2009 19:46:52 -0800
Message-ID: <200911130346.nAD3kqgU001048@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:29160 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732AbZKMDqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 22:46:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this perticular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6.

Please NOTE we've updated patches to a newer code, based on Brocade
Release 2.1, that has enhancements for better control path
synchronization.

We have addressed the following is a list of review comments apart
from the required clean-up:

1. Removed all the module parameters except bnad_ioc_auto_recover

2. Removed all the proprietary implementation of a driver debug
   logging facility.

3. Fixed bnad_netpoll() for MSIX

4. Removed macros e.g.   NETIF_F_*, SKB_GSO_TCPV4, VMK*,
   BNAD_RXBUF_HEADROOM etc.

5. Removed bnad_ioctl() function

6. Remove call to netif_stop_queue after netif_carrier_off()

7. Removed bnad_get_stats_count()

8. Change return type to netdev_tx_t for bnad_start_xmit()

9. Remove superfluous casting to irq_handler_t

10. Use setup_timer() for timer initialization, use msecs_to_jiffies()
    in mod_timer()

11. Convert BNAD_RESET_Q to a function

12. Removed pci_saved_config from bnad structure

13. Used module_param() to validate module params

14. Removed OS abstraction
        - All endian-ness conversion functions
        - Changed bfa_boolean to bool
        - Changed BFA_[TRUE|FALSE] to true/false

15. Changed naming style for structures : dropped ._s. suffix

16. Removed setting of netdev->trans_start & netdev->last_rx

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


