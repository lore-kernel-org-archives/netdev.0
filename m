From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Second batch of cpsw patches
Date: Wed, 24 Apr 2013 20:48:21 +0200
Message-ID: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41166 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757332Ab3DXSsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:48:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this is my second batch fixing modules load/unload and the threaded
irq thingy which started this :)
I'm not sure about the slave & dual_mac thingy but I think I got it right.

Do you think it would split the net_device struct away from cpsw_priv so
you copy almost everything from one struct to the other in case of dual_mac?

Sebastian
