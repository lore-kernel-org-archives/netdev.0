From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH] net: cpsw: do not register cpts twice
Date: Sun, 16 Mar 2014 16:36:28 +0100
Message-ID: <1394984189-1659-1-git-send-email-b.spranger@linutronix.de>
Cc: tglx@linutronix.de, Mugunthan V N <mugunthanvnm@ti.com>,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:40193 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbaCPPgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 11:36:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f280e89a (drivers: net: cpsw: fix for cpsw crash when build as module)
moved cpts_register()/cpts_unregister() to ndo_open()/ndo_stop(), but failed
to remove cpts_register in cpsw_probe(). 

Benedikt Spranger (1):
  net: cpsw: do not register cpts twice

 drivers/net/ethernet/ti/cpsw.c | 4 ----
 1 file changed, 4 deletions(-)

-- 
1.9.0
