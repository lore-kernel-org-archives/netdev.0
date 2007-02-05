From: Robert Hancock <hancockr@shaw.ca>
Subject: forcedeth problems on 2.6.20-rc6-mm3
Date: Sun, 04 Feb 2007 23:13:09 -0600
Message-ID: <45C6BCE5.90103@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]:63437 "EHLO
	pd3mo2so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbXBEFNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 00:13:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Something's busted with forcedeth in 2.6.20-rc6-mm3 for me relative to 
2.6.20-rc6. There's no errors in dmesg, but it seems no packets ever get 
received and so the machine can't get an IP address. I tried reverting 
all the -mm changes to drivers/net/forcedeth.c, which didn't help. The 
network controller shares an IRQ with the USB OHCI controller which is 
receiving interrupts, so it doesn't seem like an interrupt routing 
problem, though I suppose something wierd could be happening there.

This is on an Asus A8N-SLI Deluxe (CK804 chipset) on x86_64.

Any suggestions on how to debug/what to try reverting to see what's 
causing this?

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/
