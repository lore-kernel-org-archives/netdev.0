From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [PATCH 5/9] MIPS: xilfpga: Update DT node and specify uart irq
Date: Mon, 15 Aug 2016 14:55:31 +0100
Message-ID: <1471269335-58747-6-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jason@lakedaemon.net>, <marc.zyngier@arm.com>,
	<Zubair.Kakakhel@imgtec.com>, <linux-mips@linux-mips.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:26513 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcHON4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 09:56:02 -0400
In-Reply-To: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the DT node with the UART irq

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
---
 arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
index 8db660b..d285c8d 100644
--- a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
+++ b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
@@ -50,6 +50,9 @@
 		reg-offset = <0x1000>;
 
 		clocks	= <&ext>;
+
+		interrupt-parent = <&axi_intc>;
+		interrupts = <0>;
 	};
 };
 
-- 
1.9.1
