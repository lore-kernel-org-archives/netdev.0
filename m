From: Felix Radensky <felix@embedded-sol.com>
Subject: tg3 and Broadcom PHY driver
Date: Sun, 27 Sep 2009 00:32:18 +0300
Message-ID: <4ABE8862.3060308@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:60070 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbZIZVcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 17:32:18 -0400
Received: from bzq-82-81-138-186.red.bezeqint.net ([82.81.138.186]:50438 helo=felix-laptop.lan)
	by vega.surpasshosting.com with esmtpa (Exim 4.69)
	(envelope-from <felix@embedded-sol.com>)
	id 1MresS-00017l-BO
	for netdev@vger.kernel.org; Sat, 26 Sep 2009 17:32:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've noticed that in linux-2.6.31 I have to make tg3 driver modular, due to
its dependency on Broadcom PHY driver. If both tg3 and PHY driver are
compiled into the kernel, tg3 fails to detect a PHY, apparently because PHY
driver is loaded later. I'm using BCM57760 on embedded powerpc platform
(MPC8536).

How can I make tg3 work when it's compiled into the kernel ?

Thanks.

Felix.
