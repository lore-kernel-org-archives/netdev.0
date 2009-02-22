From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Yet more fixes to etherh.c
Date: Sun, 22 Feb 2009 08:19:47 +0000
Message-ID: <20090222081947.GF16596@n2100.arm.linux.org.uk>
References: <20090221193633.GD16596@n2100.arm.linux.org.uk> <20090221.234448.26454123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:49294 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbZBVIUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:20:02 -0500
Content-Disposition: inline
In-Reply-To: <20090221.234448.26454123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2009 at 11:44:48PM -0800, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Sat, 21 Feb 2009 19:36:33 +0000
> 
> > Further to a71558d, this is round five of fixes to make etherh work
> > again. As mainline kernels stand, the fixes in b9a9b4b were the wrong
> > approach.
>  ...
> > Fix up b9a9b4b by making etherh's net_device_ops refer to the internal
> > lib8390 functions, and remove the build of the ISA 8390.c driver.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Applied to net-next-2.6, thanks Russell.
> 
> You mention this as a fix against mainline, but your patch
> only applied to net-next-2.6 because the "eth_set_mac_addr"
> fix to this driver only exists there.

Hmm, I don't see the problem.  What's currently in mainline is:

        .ndo_set_mac_address    = eth_mac_addr,

which is what's in the context lines of this patch.  I pushed this
myself in a71558d.

> Let me know if you want me to propagate both changes to net-2.6
> and push to Linus.

Definitely, these patches are fixing regressions, so should be submitted
to Linus for 2.6.29.
