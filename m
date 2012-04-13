From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1: fix kernel panic in case of DMA errors
Date: Fri, 13 Apr 2012 13:35:59 -0400 (EDT)
Message-ID: <20120413.133559.1074868352058413273.davem@davemloft.net>
References: <1334160903-988902-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: antonz@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab2DMRgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:36:03 -0400
In-Reply-To: <1334160903-988902-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Zelenoff <antonz@parallels.com>
Date: Wed, 11 Apr 2012 20:15:03 +0400

> Problem:
> There was two separate work_struct structures which share one
> handler. Unfortunately getting atl1_adapter structure from
> work_struct in case of DMA error was done from incorrect
> offset which cause kernel panics.
> 
> Solution:
> The useless work_struct for DMA error removed and
> handler name changed to more generic one.
> 
> Signed-off-by: Tony Zelenoff <antonz@parallels.com>

Applied and queued up for -stable, thanks.
