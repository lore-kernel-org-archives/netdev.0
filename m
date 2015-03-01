From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rxrpc: terminate retrans loop when sending of skb
 fails
Date: Sun, 01 Mar 2015 14:01:10 -0500 (EST)
Message-ID: <20150301.140110.685132612325090680.davem@davemloft.net>
References: <1425120697-27791-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com,
	linux-afs@lists.infradead.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbbCATBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:01:12 -0500
In-Reply-To: <1425120697-27791-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 28 Feb 2015 11:51:36 +0100

> Typo, 'stop' is never set to true.
> Seems intent is to not attempt to retransmit more packets after sendmsg
> returns an error.
> 
> This change is based on code inspection only.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
