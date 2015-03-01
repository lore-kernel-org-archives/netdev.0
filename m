From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] rxrpc: don't multiply with HZ twice
Date: Sun, 01 Mar 2015 14:01:18 -0500 (EST)
Message-ID: <20150301.140118.79848188973600589.davem@davemloft.net>
References: <1425120697-27791-1-git-send-email-fw@strlen.de>
	<1425120697-27791-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com,
	linux-afs@lists.infradead.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbCATBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:01:20 -0500
In-Reply-To: <1425120697-27791-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 28 Feb 2015 11:51:37 +0100

> rxrpc_resend_timeout has an initial value of 4 * HZ; use it as-is.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
