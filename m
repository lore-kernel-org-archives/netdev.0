From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [0/6] Bugfixes for pasemi_mac
Date: Wed, 26 Sep 2007 16:22:00 -0500
Message-ID: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:41572 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755592AbXIZVSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:18:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Following patches are for various bug fixes against current netdev-2.6.24
upstream branch. Please apply.


[PATCH] [1/6] pasemi_mac: fix build break in pasemi_mac_probe()
[PATCH] [2/6] pasemi_mac: fix build break in pasemi_mac_clean_rx()
[PATCH] [3/6] pasemi_mac: set interface speed correctly on XAUI ports
[PATCH] [4/6] pasemi_mac: flags as passed to spin_*_irqsave() should be unsigned long
[PATCH] [5/6] pasemi_mac: don't enable rx before there are buffers on the ring
[PATCH] [6/6] pasemi_mac: pass in count of buffers to replenish rx ring with


Thanks,

-Olof
