From: Andrew Morton <akpm@osdl.org>
Subject: b44.c on arm
Date: Fri, 26 Jan 2007 23:41:47 -0800
Message-ID: <20070126234147.2ffc2cb5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44155 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbXA0HmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Jan 2007 02:42:02 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


drivers/net/b44.c: In function `b44_sync_dma_desc_for_cpu':
drivers/net/b44.c:144: warning: implicit declaration of function `dma_sync_single_range_for_cpu'

several architectures appear to not implement dma_sync_single_range_for_cpu()
