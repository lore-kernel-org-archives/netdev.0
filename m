From: Greg Fitzgerald <netzdamon@gmail.com>
Subject: sky2 hangs
Date: Fri, 19 Sep 2008 20:23:27 -0400
Message-ID: <20080920002324.GA3939@betsy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:53703 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYITAXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 20:23:34 -0400
Received: by wa-out-1112.google.com with SMTP id j37so525807waf.23
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 17:23:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hope I am sending this to the right place. Have the sky2 network card.
Internet will die out randomly, re-probing the sky2 module usually solves
the problem. According to dmesg the receiver is hanging.

sky2 eth0: hung mac 0:81 fifo 3 (86:89)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
sky2 eth0: enabling interface
sky2 eth0: Link is up at 10 Mbps, half duplex, flow control none
sky2 eth0: hung mac 0:11 fifo 194 (51:45)
sky2 eth0: receiver hang detected

This top half happens 3 or 4 times, then I'll start to get this extra
output in dmesg after that.

sky2 eth0: disabling interface
ACPI: PCI interrupt for device 0000:02:00.0 disabled
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:02:00.0 to 64
sky2 0000:02:00.0: v1.21 addr 0xcdefc000 irq 19 Yukon-EC (0xb6) rev 2
sky2 eth0: addr 00:17:31:9b:ca:89
sky2 eth0: enabling interface
sky2 eth0: Link is up at 10 Mbps, half duplex, flow control none
sky2 eth0: disabling interface
sky2 eth0: enabling interface
sky2 eth0: Link is up at 10 Mbps, half duplex, flow control none

Some where in between all this, it actually gets to the point where I
totally loose my connection. Sometimes it will come back up and I'm
perfectly fine.

If I can provide any other information please let me know.

Oh, been having this problem for some time now. Current version of the
my kernel is 2.6.26.5.

--Greg
