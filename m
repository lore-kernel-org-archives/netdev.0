From: Parag Warudkar <parag.lkml@gmail.com>
Subject: 2.6.29-rc3: tg3 dead after resume
Date: Wed, 28 Jan 2009 19:14:11 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	torvalds@linuxfoundation.org, akpm@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:33471 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760334AbZA2AOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 19:14:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With 2.6.29-rc3 suspend/resume has started working on my workstation again 
(did not resume with rc2 - not sure when it broke) but tg3 is dead 
after resume.

This is similar to the issue reported back in Jul 2007 - 
http://kerneltrap.org/mailarchive/linux-kernel/2007/8/1/154073/thread 
which was fixed with a patch to unconditionally save/restore pci config 
space - that one is still in tg3.c.

After resume tg3 complains that no firmware is running and eth0 is 
non-existent. Rmmoding and modprobing tg3 again causes some timeouts and 
errors from tg3 and the link still doesn't work.

Reboot fixes it.


Parag
