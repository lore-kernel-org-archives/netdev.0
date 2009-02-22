From: David Miller <davem@davemloft.net>
Subject: Re: Yet more fixes to etherh.c
Date: Sat, 21 Feb 2009 23:44:48 -0800 (PST)
Message-ID: <20090221.234448.26454123.davem@davemloft.net>
References: <20090221193633.GD16596@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbZBVHpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 02:45:06 -0500
In-Reply-To: <20090221193633.GD16596@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 21 Feb 2009 19:36:33 +0000

> Further to a71558d, this is round five of fixes to make etherh work
> again. As mainline kernels stand, the fixes in b9a9b4b were the wrong
> approach.
 ...
> Fix up b9a9b4b by making etherh's net_device_ops refer to the internal
> lib8390 functions, and remove the build of the ISA 8390.c driver.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied to net-next-2.6, thanks Russell.

You mention this as a fix against mainline, but your patch
only applied to net-next-2.6 because the "eth_set_mac_addr"
fix to this driver only exists there.

Let me know if you want me to propagate both changes to net-2.6
and push to Linus.
