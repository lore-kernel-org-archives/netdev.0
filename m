From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: atl1c from linux-4.0.5 fails the probe
Date: Wed, 24 Jun 2015 15:29:18 +0300
Message-ID: <20150624122918.GA69037@lav-w.yar.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ysu1-bbox2-vlan904.yar.ru ([213.187.127.39]:32777 "EHLO
	bbox2.yar.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669AbbFXMkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 08:40:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

https://bugzilla.redhat.com/show_bug.cgi?id=1234825

After upgrade kernel 3.19.8-100.fc20.i686 -> kernel-4.0.5-200.fc21.i686 the
module atl1c fails to detect my ethernet controller.

It produces the following error message:

Jun 23 10:58:38 node2 kernel: [    1.397542] atl1c 0000:02:00.0: MAC state machine can't be idle since disabled for 10ms second
Jun 23 10:58:38 node2 kernel: [    1.397624] atl1c: probe of 0000:02:00.0 failed with error -5

Additional info:
02:00.0 Ethernet controller: Qualcomm Atheros AR8151 v2.0 Gigabit Ethernet (rev c0)
	Subsystem: Gigabyte Technology Co., Ltd Device e000
	Flags: bus master, fast devsel, latency 0, IRQ 28
	Memory at f7c00000 (64-bit, non-prefetchable) [size=256K]
	I/O ports at e000 [size=128]
	Capabilities: [40] Power Management version 3
	Capabilities: [48] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [58] Express Endpoint, MSI 00
	Capabilities: [6c] Vital Product Data
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [180] Device Serial Number ff-ce-fb-f0-50-e5-49-ff

-- 
   Alexander.
