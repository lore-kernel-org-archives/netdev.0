From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: netdevice mtu assumptions documentation
Date: Sat, 07 Jul 2007 23:04:48 -0700 (PDT)
Message-ID: <20070707.230448.51861832.davem@davemloft.net>
References: <20070706112623.478aedcf@freepuppy.rosehill.hemminger.net>
	<20070706113117.68184d0e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751988AbXGHGE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 02:04:26 -0400
In-Reply-To: <20070706113117.68184d0e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 6 Jul 2007 11:31:17 -0700

> Document the expectations about device MTU handling.
> The documentation about oversize packet handling is probably too
> loose.
> 
> IMHO devices should drop oversize packets for robustness,
> but many devices allow it now. For example, if you set mtu to 1200
> bytes, most ether devices will allow a 1500 byte frame in.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.

I agree that drivers should drop oversized frames, otherwise
setting up PMTU test scenerios is more difficult than it
really needs to be.
