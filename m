From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] tipc: fix semaphore handling
Date: Fri, 14 Dec 2007 11:31:23 -0800 (PST)
Message-ID: <20071214.113123.124033216.davem@davemloft.net>
References: <200712140002.lBE02b3G025494@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	jon.maloy@ericsson.com, kjwinchester@gmail.com,
	per.liden@ericsson.com, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49845
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764207AbXLNTba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:31:30 -0500
In-Reply-To: <200712140002.lBE02b3G025494@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 13 Dec 2007 16:02:36 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> As noted by Kevin, tipc's release() does down_interruptible() and ignores the
> return value.  So if signal_pending() we'll end up doing up() on a non-downed
> semaphore.  Fix.
> 
> Cc: Kevin Winchester <kjwinchester@gmail.com>
> Cc: Per Liden <per.liden@ericsson.com>
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Allan Stephens <allan.stephens@windriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This is already in my net-2.6 tree, but thanks for resubmitting
anyways :)
