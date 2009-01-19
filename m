From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 fails to initialize in current -git
Date: Mon, 19 Jan 2009 11:52:46 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1A07DD00@orsmsx507.amr.corp.intel.com>
References: <496AE0A5.903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39231 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314AbZASTwu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 14:52:50 -0500
In-Reply-To: <496AE0A5.903@trash.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> I get this with 2.6.29-rc1
> 
> [    1.415322] Intel(R) PRO/1000 Network Driver - version
> 7.3.20-k3-NAPI [    1.415402] Copyright (c) 1999-2006 Intel
> Corporation. [    1.426013] e1000 0000:00:0c.0: enabling device (0000
> -> 0003) [    1.426101] e1000 0000:00:0c.0: PCI INT A -> GSI 17
> (level, low) -> 
> IRQ 17
> [    1.426187] e1000 0000:00:0c.0: PCI: Disallowing DAC for device
> [    1.426277] e1000 0000:00:0c.0: setting latency timer to 64
> [    1.495882] e1000: EEPROM initialization failed
> [    1.516170] e1000 0000:00:0c.0: PCI INT A disabled
> [    1.516252] e1000: probe of 0000:00:0c.0 failed with error -5
> 
> and the device is not registered. If someone wants me to test patches
> or do something else, just let me know.


are you still having this issue?  My guess is that it may be because
the pci_enable_device logic for devices in D3 got broken, but I think 
that is now fixed.

Jesse