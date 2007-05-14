From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: tg3 does not want to go up (config space problems).
Date: Mon, 14 May 2007 19:26:25 +0400
Message-ID: <20070514152625.GA31306@2ka.mipt.ru>
References: <20070514145419.GA19679@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59727 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344AbXENP03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 11:26:29 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id l4EFQPAv003976
	for <netdev@vger.kernel.org>; Mon, 14 May 2007 19:26:27 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id l4EFQPkm003974
	for netdev@vger.kernel.org; Mon, 14 May 2007 19:26:25 +0400
Content-Disposition: inline
In-Reply-To: <20070514145419.GA19679@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 06:54:20PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Hi.
> 
> I've cought a problem with my laptop and tg3 driver.
> Suddenly (it was turned off quite for a while) tg3 driver does not start
> up.
> PM: writing back config space on device /* tg3 device pcix id*/ at
> offset b (was 165d14e4, writing 890103c)
> offset 3 (was 0, writing 4010)
> offset 2 (was 2000000, writing 2000003)
> offset 1 (was 2b00000, writing 2b00006)
> offset 0 (was 165d14e4, writing 165e14e4)

This happens in tg3_chip_reset() callback in pci_restore_state().

Bits of lspci:
02:0e.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5705M_2 Gigabit Ethernet (rev 03)
Subsystem: Hewlett-Packard Company NC6000 laptop
Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 11
Memory at 90000000 (64-bit, non-prefetchable) [size=64K]
Expansion ROM at <unassigned> [disabled] [size=64K]
Capabilities: [48] Power Management version 2
Capabilities: [50] Vital Product Data
Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-

-- 
	Evgeniy Polyakov
