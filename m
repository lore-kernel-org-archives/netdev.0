From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: Add support for ndo_busy_poll
Date: Tue, 20 Aug 2013 15:09:05 -0700 (PDT)
Message-ID: <20130820.150905.44199510198057625.davem@davemloft.net>
References: <1376902939-21968-1-git-send-email-hykim@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hykim@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab3HTWJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:09:06 -0400
In-Reply-To: <1376902939-21968-1-git-send-email-hykim@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hyong-Youb Kim <hykim@myri.com>
Date: Mon, 19 Aug 2013 02:02:19 -0700

> Add the ndo_busy_poll handler. Use skb_mark_napi_id to mark receive
> packets with the napi id. For each slice, use per-slice spinlock and
> state variable to ensure that only one handler processes receive
> pacekts.
> 
> Locking, statistics counters, and the ndo_busy_poll handler follow
> those in the ixgbe driver. So, credit goes to that driver's authors.
> 
> Signed-off-by: Hyong-Youb Kim <hykim@myri.com>

Applied, but this patch had a ton of trailing whitespace which I had
to fix up.
