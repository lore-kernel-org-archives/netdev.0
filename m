From: Marin Mitov <mitov@issp.bas.bg>
Subject: [BUGs] must check return value of pci_map_single()/pci_map_page()
Date: Mon, 23 Jun 2008 14:06:22 +0300
Message-ID: <200806231406.23027.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.issp.bas.bg ([195.96.236.10]:58610 "EHLO mail.issp.bas.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586AbYFWLFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 07:05:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

According to Documentation/DMA-mapping.txt one should
check the return value of pci_map_single()/pci_map_page()
using pci_dma_mapping_error(), but many drivers do not.
(I have checked in drivers/net/* for example).

Should we add __must_check in the definitions/declarations 
of these functions/macros "to force" the check?

Best regards

Marin Mitov
