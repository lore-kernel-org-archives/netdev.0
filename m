From: David Miller <davem@davemloft.net>
Subject: Re: [NET 02/05]: dev_mcast: add multicast list synchronization
 helpers
Date: Sat, 14 Jul 2007 18:52:37 -0700 (PDT)
Message-ID: <20070714.185237.122619429.davem@davemloft.net>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
	<20070712181341.13849.58440.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763138AbXGOBwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 21:52:35 -0400
In-Reply-To: <20070712181341.13849.58440.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Jul 2007 20:13:42 +0200 (MEST)

> [NET]: dev_mcast: add multicast list synchronization helpers
> 
> The method drivers currently use to synchronize multicast lists is not
> very pretty:
> 
> - walk the multicast list
> - search each entry on a copy of the previous list
> - if new add to lower device
> - walk the copy of the previous list
> - search each entry on the current list
> - if removed delete from lower device
> - copy entire list
> 
> This patch adds a new field to struct dev_addr_list to store the
> synchronization state and adds two helper functions for synchronization
> and cleanup.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
