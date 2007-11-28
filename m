From: Andrew Morton <akpm@google.com>
Subject: drivers/net/r6040.c warnings on x86_64
Date: Tue, 27 Nov 2007 20:45:36 -0800
Message-ID: <20071127204536.61bf7921.akpm@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sten Wang <sten.wang@rdc.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:4356 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbXK1Ept (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 23:45:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/r6040.c: In function 'rx_buf_alloc':
drivers/net/r6040.c:262: warning: passing argument 2 of 'pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c: In function 'r6040_up':
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:632: warning: cast to pointer from integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:638: warning: cast to pointer from integer of different size

can we fix these please?
