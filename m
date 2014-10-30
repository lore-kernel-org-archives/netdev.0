From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] syncookies: only increment SYNCOOKIESFAILED on
 validation error
Date: Thu, 30 Oct 2014 16:54:08 -0400 (EDT)
Message-ID: <20141030.165408.1188635189578871302.davem@davemloft.net>
References: <1414634138-23238-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933938AbaJ3UyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:54:10 -0400
In-Reply-To: <1414634138-23238-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 30 Oct 2014 02:55:38 +0100

> Only count packets that failed cookie-authentication.
> We can get SYNCOOKIESFAILED > 0 while we never even sent a single cookie.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
