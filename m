From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 -next] net/core/dev: Warn on a too-short GRO frame
Date: Tue, 05 Apr 2016 19:59:00 -0400 (EDT)
Message-ID: <20160405.195900.1855517725423298273.davem@davemloft.net>
References: <1459625203-8637-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, eric.dumazet@gmail.com
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757966AbcDEX7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:59:03 -0400
In-Reply-To: <1459625203-8637-1-git-send-email-aconole@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Sat,  2 Apr 2016 15:26:43 -0400

> From: Aaron Conole <aconole@bytheb.org>
> 
> When signaling that a GRO frame is ready to be processed, the network stack
> correctly checks length and aborts processing when a frame is less than 14
> bytes. However, such a condition is really indicative of a broken driver,
> and should be loudly signaled, rather than silently dropped as the case is
> today.
> 
> Convert the condition to use net_warn_ratelimited() to ensure the stack
> loudly complains about such broken drivers.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>

Applied, thanks.
