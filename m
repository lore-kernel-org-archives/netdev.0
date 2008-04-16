From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7 net-2.6.26] [TIPC]: Remove redundant NULL check
 when discarding buffers
Date: Tue, 15 Apr 2008 19:01:57 -0700 (PDT)
Message-ID: <20080415.190157.65853407.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-5-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753071AbYDPCB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:01:56 -0400
In-Reply-To: <1208288637-15304-5-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:54 -0400

> This patch eliminates a null pointer check when discarding a
> TIPC message buffer, since kfree_skb() already handles this
> situation.
> 
> Acknowledgements to Florian Westphal (fw@strlen.de> for
> suggesting this enhancement.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied, thanks.
