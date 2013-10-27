From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 next] be2net: add support for ndo_busy_poll
Date: Sun, 27 Oct 2013 17:05:47 -0400 (EDT)
Message-ID: <20131027.170547.916679037747045857.davem@davemloft.net>
References: <1382677816-7762-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672Ab3J0VFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 17:05:48 -0400
In-Reply-To: <1382677816-7762-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 25 Oct 2013 10:40:16 +0530

> Includes:
> - ndo_busy_poll implementation
> - Locking between napi and busy_poll
> - Fix rx_post_starvation (replenish rx-queues in out-of-mememory scenario)
>   logic to accomodate busy_poll.
> 
> v2 changes:
> [Eric D.'s comment] call alloc_pages() with GFP_ATOMIC even in ndo_busy_poll
> context as it is not allowed to sleep.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.
