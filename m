From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] forcedeth: napi schedule lock fix
Date: Fri, 09 Jan 2009 23:13:23 -0800 (PST)
Message-ID: <20090109.231323.225694598.davem@davemloft.net>
References: <4967BBB5.9080803@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752525AbZAJHNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:13:22 -0500
In-Reply-To: <4967BBB5.9080803@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 09 Jan 2009 16:03:49 -0500

> This patch fixes a potential race condition between scheduling napi and completing napi poll. The call to netif_rx_schedule should be under protection of the lock (as is the completion), otherwise, interrupts could be masked off.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Another patch I had to apply by hand.

The 'dev' argument was removed from the netif_*() NAPI interfaces
and then were converted to napi_*() in the net-2.6 tree.
