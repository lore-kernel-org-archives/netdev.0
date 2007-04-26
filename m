From: David Miller <davem@davemloft.net>
Subject: Re: [patch 05/15] net: tun/tap: fixed hw address handling
Date: Thu, 26 Apr 2007 01:01:12 -0700 (PDT)
Message-ID: <20070426.010112.58788436.davem@davemloft.net>
References: <200704260727.l3Q7RP9D023955@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxkernel@bristyle.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933635AbXDZIBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:01:04 -0400
In-Reply-To: <200704260727.l3Q7RP9D023955@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:24 -0700

> From: Brian Braunstein <linuxkernel@bristyle.com>
> 
> Fixed tun/tap driver's handling of hw addresses.  The hw address is stored
> in both the net_device.dev_addr and tun.dev_addr fields.  These fields were
> not kept synchronized, and in fact weren't even initialized to the same
> value.  Now during both init and when performing SIOCSIFHWADDR on the tun
> device these values are both updated.  However, if SIOCSIFHWADDR is
> performed on the net device directly (for instance, setting the hw address
> using ifconfig), the tun device does not get updated.  Perhaps the
> tun.dev_addr field should be removed completely at some point, as it is
> redundant and net_device.dev_addr can be used anywhere it is used.
> 
> Signed-off-by: Brian Braunstein <linuxkernel@bristyle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
