From: Ondrej Zary <linux@rainbow-software.org>
Subject: de4x5 hangs with SMP: synchronize_irq() in interrupt handler?
Date: Tue, 21 Sep 2010 22:30:49 +0200
Message-ID: <201009212230.51036.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:44621 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753922Ab0IUUbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 16:31:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I'm trying to get two Compex FreedomLine 32 PnP-PCI2 cards to work (21041-AA 
and 21041-PA) - there are problems with de2104x driver (one of the cards does 
not work at all and the other one switches to non-existing AUI port when the 
link goes down and never switches back to RJ45) and I know that de4x5 driver 
worked for me in past.

Loading de4x5 causes the machine to hang immediately. It hangs at 
synchronize_irq() call from de4x5_interrupt(). Commenting out this allows the 
driver to work. Without SMP, synchronize_irq() is redefined to barrier() so 
it works.

I don't have a clue how to fix this properly - does anyone know?

-- 
Ondrej Zary
