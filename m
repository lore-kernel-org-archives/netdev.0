From: Patrick McHardy <kaber@trash.net>
Subject: e1000 fails to initialize in current -git
Date: Mon, 12 Jan 2009 07:18:13 +0100
Message-ID: <496AE0A5.903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56616 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695AbZALGSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 01:18:15 -0500
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTPSA id 6DF60948AE
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 07:18:14 +0100 (MET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I get this with 2.6.29-rc1

[    1.415322] Intel(R) PRO/1000 Network Driver - version 7.3.20-k3-NAPI
[    1.415402] Copyright (c) 1999-2006 Intel Corporation.
[    1.426013] e1000 0000:00:0c.0: enabling device (0000 -> 0003)
[    1.426101] e1000 0000:00:0c.0: PCI INT A -> GSI 17 (level, low) -> 
IRQ 17
[    1.426187] e1000 0000:00:0c.0: PCI: Disallowing DAC for device
[    1.426277] e1000 0000:00:0c.0: setting latency timer to 64
[    1.495882] e1000: EEPROM initialization failed
[    1.516170] e1000 0000:00:0c.0: PCI INT A disabled
[    1.516252] e1000: probe of 0000:00:0c.0 failed with error -5

and the device is not registered. If someone wants me to test patches
or do something else, just let me know.

