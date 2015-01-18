From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix socket list regression in new nl api
Date: Sun, 18 Jan 2015 00:27:16 -0500 (EST)
Message-ID: <20150118.002716.615764399085719268.davem@davemloft.net>
References: <1421407840-30726-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbARF1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:27:18 -0500
In-Reply-To: <1421407840-30726-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Fri, 16 Jan 2015 12:30:40 +0100

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> Commit 07f6c4bc (tipc: convert tipc reference table to use generic
> rhashtable) introduced a problem with port listing in the new netlink
> API. It broke the resume functionality resulting in a never ending
> loop. This was caused by starting with the first hash table every time
> subsequently never returning an empty skb (terminating).
> 
> This patch fixes the resume mechanism by keeping a logical reference
> to the last hash table along with a logical reference to the socket
> (port) that didn't fit in the previous message.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
