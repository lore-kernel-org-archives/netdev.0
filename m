From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: dgrs: sparse warnings
Date: Thu, 6 Sep 2007 13:55:47 +0100
Message-ID: <20070906135547.13bb3326@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55535 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754380AbXIFMzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 08:55:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dgrs driver is crap and assumes direct access to PCI iomem.

  CHECK   drivers/net/dgrs.c
drivers/net/dgrs.c:314:20: warning: cast removes address space of expression
drivers/net/dgrs.c:330:12: warning: incorrect type in argument 1 (different address spaces)
drivers/net/dgrs.c:330:12:    expected void volatile [noderef] <asn:2>*addr
drivers/net/dgrs.c:330:12:    got void *<noident>
drivers/net/dgrs.c:1003:14: warning: incorrect type in assignment (different address spaces)
drivers/net/dgrs.c:1003:14:    expected char *[usertype] vmem
drivers/net/dgrs.c:1003:14:    got void [noderef] <asn:2>*
drivers/net/dgrs.c:1023:17: warning: incorrect type in argument 1 (different address spaces)
drivers/net/dgrs.c:1023:17:    expected void volatile [noderef] <asn:2>*addr
drivers/net/dgrs.c:1023:17:    got char *[usertype] vmem
drivers/net/dgrs.c:1052:16: warning: incorrect type in argument 1 (different address spaces)
drivers/net/dgrs.c:1052:16:    expected void volatile [noderef] <asn:2>*addr
drivers/net/dgrs.c:1052:16:    got char *[usertype] vmem
drivers/net/dgrs.c:1106:16: warning: incorrect type in argument 1 (different address spaces)
drivers/net/dgrs.c:1106:16:    expected void volatile [noderef] <asn:2>*addr
drivers/net/dgrs.c:1106:16:    got char *[usertype] vmem
drivers/net/dgrs.c:1369:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/dgrs.c:1369:15:    expected void volatile [noderef] <asn:2>*addr
drivers/net/dgrs.c:1369:15:    got char *[usertype] vmem
drivers/net/dgrs.c:1371:12: warning: incorrect type in argument 1 (different address spaces)
drivers/net/dgrs.c:1371:12:    expected void volatile [noderef] <asn:2>*addr
drivers/net/dgrs.c:1371:12:    got unsigned char [usertype] *<noident>

Perhaps we should just mark it as BROKEN in Kconfig
