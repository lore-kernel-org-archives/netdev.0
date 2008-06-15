From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: r8169 rx descriptors
Date: Mon, 16 Jun 2008 00:26:48 +0300
Message-ID: <20080615211030.M80450@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:50724 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbYFOV1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 17:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From NetBSD sources
http://cvsweb.netbsd.org/bsdweb.cgi/~checkout~/src/sys/dev/ic/rtl8169.c?rev=1.14.2.7&content-type=text/plain&logsort=rev&f=h&only_with_tag=netbsd-3

 *      o RX and TX DMA rings can have up to 1024 descriptors
 *        (the 8139C+ allows a maximum of 64)



Why in Linux source:

#define NUM_TX_DESC     64      /* Number of Tx descriptor registers */
#define NUM_RX_DESC     256     /* Number of Rx descriptor registers */

Is it possible to do them changeable over ethtool -g ?
Maybe NetBSD developers signed NDA and have access to datasheets?

Also i seen in one patch from Realtek , something similar to
-#define RX_DMA_BURST    6       /* Maximum PCI burst, '6' is 1024 */
+#define RX_DMA_BURST    7       /* Maximum PCI burst, '6' is 1024 */

Why it is reverted or not applied?


In sources from Realtek website it is 
#define RX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
#define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */

I will try to change burst settings on my router, and waiting comments about 

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

