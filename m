From: Jens Stroebel <drifter@bcsoft.de>
Subject: r8169: 2.6.22rc6+patches works, but 2.6.21.5 and 2.6.22rc6 without
 patches->network transfer blocking
Date: Thu, 28 Jun 2007 20:08:35 +0200
Message-ID: <4683F923.80508@bcsoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com
To: netdev list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:56223 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072AbXF1SIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 14:08:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

			Hello.

The hardware involved:

Motherboard: Asus P5B
lspci:
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet
 controller (rev 01)

First the non-working scenario (2.6.21.5, 2.6.22rc6 unpatched):
During the use of network connections, we experience "network transfer
stops" during which a transfer seems to stall completely for many
seconds, after which the transfer runs as if nothing happened.

This is reproducable everytime w.
 svn co http://svnserver/svn/tree
   (hangs VERY LONG)

Now with all patches under
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc3/r8169-20070527/

    and the single patch
http://www.fr.zoreil.com/people/francois/misc/20070619-2.6.22-rc5-r8169-test.patch

the problem is gone. Without the single patch, the problem persists.

Is there any possibility to get this fix working in 2.6.21.5? Would it
be possible to apply the single patch to 2.6.21.5 and get a working
driver? Or would it be possible to create the fixing patch for the
driver in 2.6.21.5?

		Greets,
		  Jens
-- 
drifter@bcsoft.de
			23.....56.......drifting
By caffeine alone I set my mind in motion, By the beans of Java
do thoughts acquire speed,  hands acquire shaking,  the shaking
becomes a warning, By caffeine alone do I set my mind in motion
