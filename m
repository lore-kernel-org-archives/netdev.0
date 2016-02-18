From: David Miller <davem@davemloft.net>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on
 i211 using a device tree blob V4
Date: Thu, 18 Feb 2016 10:22:37 -0500 (EST)
Message-ID: <20160218.102237.2040974178950445305.davem@davemloft.net>
References: <56C506FD.5040408@gmail.com>
	<20160217.212910.1758016077144502307.davem@davemloft.net>
	<97579B9E-E7C6-4DBE-B1A2-027C2EA7F754@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: jotihojr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426370AbcBRPWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:22:41 -0500
In-Reply-To: <97579B9E-E7C6-4DBE-B1A2-027C2EA7F754@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Holland <jotihojr@gmail.com>
Date: Thu, 18 Feb 2016 08:53:07 +0100

> The PCI path in eth_platform_get_mac_address() didn't return a devicetree node...

Then fix your platform such that pci_device_to_OF_node() works
properly instead of adding localized hacks to device drivers.

Jeff, do not apply this patch.
