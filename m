From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next 0/2] bnx2: allow sleep during allocation
Date: Thu, 15 Jul 2010 10:25:35 -0400
Message-ID: <20100715142530.12504.80404.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Cc: Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933300Ab0GOOZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 10:25:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have Fedora bug report about memory allocation failure in bnx2_open
(https://bugzilla.redhat.com/show_bug.cgi?id=612861). To prevent
failure we can allow allocator to sleep. Both patches add
GFP_KERNEL flag where possible, first patch in alloc API, second
in DMA API (after conversion from pci_dma_*).

Stanislaw
