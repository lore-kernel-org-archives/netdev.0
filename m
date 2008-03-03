From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000e fails to find IRQ
Date: Mon, 03 Mar 2008 10:05:43 -0800
Message-ID: <47CC3DF7.20907@intel.com>
References: <20080303124443.52gfbwwmahxf7wmk@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24058 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760885AbYCCSL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 13:11:26 -0500
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by ahkok-mobl.jf.intel.com (Postfix) with ESMTP id 09B1D40372
	for <netdev@vger.kernel.org>; Mon,  3 Mar 2008 10:05:44 -0800 (PST)
In-Reply-To: <20080303124443.52gfbwwmahxf7wmk@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sami Farin wrote:
> e1000e says:
> [  844.557662] ACPI: PCI interrupt for device 0000:00:19.0 disabled
> [  848.739930] e1000e: Intel(R) PRO/1000 Network Driver - 0.2.0
> [  848.739936] e1000e: Copyright (c) 1999-2007 Intel Corporation.
> 
> e1000 v 7.3.20-k2 and 7.6.15.4 work:
> [  883.836173] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
> [  883.836179] Copyright (c) 1999-2006 Intel Corporation.
> [  883.836251] ACPI: PCI Interrupt 0000:00:19.0[A] -> GSI 20 (level, low) -> IRQ 20
> [  883.836266] PCI: Setting latency timer of device 0000:00:19.0 to 64
> [  883.853782] e1000: 0000:00:19.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:19:d1:00:5f:01
> [  883.853789] e1000: 0000:00:19.0: e1000_probe: This device (id 8086:104a) will no longer be supported by this driver in the future.
> [  883.853909] e1000: 0000:00:19.0: e1000_probe: please use the "e1000e" driver instead.
> [  883.931690] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> [  883.993761] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [  885.423079] e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
> [  885.423085] e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO
> [  885.429521] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 
> I have Intel DQ965GF mobo, version CO96510J.86A.6002.2007.1125.2356,
> Linux 2.6.24.3.

a bit unclear what kernel version you are actually using here... the device that
you have (ich8 onboard lan) is NOT supported in 2.6.24.x by e1000e - you'll have
to use the e1000 driver until 2.6.25 ships.

what kernel version are you using here?

Auke
