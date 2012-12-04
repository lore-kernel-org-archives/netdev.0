From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event
 via rtnetlink
Date: Tue, 04 Dec 2012 13:09:14 -0500 (EST)
Message-ID: <20121204.130914.1457976839967676240.davem@davemloft.net>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab2LDSJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 13:09:16 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  4 Dec 2012 12:13:34 +0100

> The goal of this serie is to be able to monitor multicast activities via
> rtnetlink.
> 
> The main changes are:
>  - when user dumps mfc entries it now get all entries, included the unresolved
>    cache.
>  - kernel sends rtnetlink when it adds/deletes mfc entries.
> 
> As usual, the patch against iproute2 will be sent once the patches are included and
> net-next merged. I can send it on demand.

This looks good, applied, thanks Nicolas.

The one thing I worry about are those 64-bit statistics.  I fear that they
not be 64-bit aligned in the final netlink message.  This matters on cpus
that trap on unaligned loads/stores, such as sparc and MIPS.

Can you validate this?
