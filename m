From: Andrew Morton <akpm@linux-foundation.org>
Subject: baycom_ser_fdx changes in git-netdev-all
Date: Sun, 8 Apr 2007 13:52:26 -0700
Message-ID: <20070408135226.e9c7223a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	Folkert van Heusden <folkert@vanheusden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56705 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXDHUwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2007 16:52:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On sparc64:

drivers/net/hamradio/baycom_ser_fdx.c: In function `ser12_open':
drivers/net/hamradio/baycom_ser_fdx.c:417: error: `NR_IRQS' undeclared (first use in this function)                                                             

sorry, I should have picked this up earlier, but I've been skipping sparc64
builds because I incorrectly thought it was missing utrace support.

