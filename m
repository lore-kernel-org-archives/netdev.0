From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] tulip: Disable debugging messages by default
Date: Mon, 18 Jul 2011 14:40:35 +0200
Message-ID: <201107181440.35886.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40059 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752102Ab1GRMki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 08:40:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With debugging messages enabled by default, one user complained [1]
that his log was spammed with these messages:

[ 6233.528227] dmfe: tdes0=7fff0000
[ 6237.651056] dmfe: tdes0=7fff0000
[ 6237.651060] dmfe: tdes0=7fff0000
[ 6237.696019] dmfe: tdes0=7fff0000
[ 6237.696022] dmfe: tdes0=7fff0000
[ 6238.028810] dmfe: tdes0=7fff0000
[ 6238.028814] dmfe: tdes0=7fff0000
[ 6238.073544] dmfe: tdes0=7fff0000
[ 6238.073547] dmfe: tdes0=7fff0000

With dynamic debugging available, I think it makes no sense to enable
debugging messages by default, especially for such old drivers which
aren't been actively developed any longer.

[1] http://lists.opensuse.org/opensuse-kernel/2011-07/msg00060.html

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Grant Grundler <grundler@parisc-linux.org>
Cc: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/Makefile |    2 --
 1 file changed, 2 deletions(-)

--- a/drivers/net/tulip/Makefile
+++ b/drivers/net/tulip/Makefile
@@ -2,8 +2,6 @@
 # Makefile for the Linux "Tulip" family network device drivers.
 #
 
-ccflags-$(CONFIG_NET_TULIP)	:= -DDEBUG
-
 obj-$(CONFIG_PCMCIA_XIRCOM)	+= xircom_cb.o
 obj-$(CONFIG_DM9102)		+= dmfe.o
 obj-$(CONFIG_WINBOND_840)	+= winbond-840.o

-- 
Jean Delvare
Suse L3
