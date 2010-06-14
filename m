From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix for race with 8259(8|9) during
 shutdown
Date: Sun, 13 Jun 2010 18:21:26 -0700 (PDT)
Message-ID: <20100613.182126.39175323.davem@davemloft.net>
References: <20100611232029.31430.75582.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	asaitou@users.sourceforge.net, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58332
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754948Ab0FNBVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 21:21:15 -0400
In-Reply-To: <20100611232029.31430.75582.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Jun 2010 16:20:29 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> There is a small window where the watchdog could be running as the
> interface is brought down on a NIC with two ports wired back to back.
> If ixgbe_update_status is then called can lead to a panic.  This patch
> allows the update to bail if we are in that condition.
> 
> This issue was orignally reported and fix proposed by Akihiko Saitou.
> 
> CC: Akihiko Saitou <asaitou@users.sourceforge.net>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
