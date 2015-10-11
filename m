From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: drop frames with attached skb->sk in
 forwarding
Date: Sun, 11 Oct 2015 05:33:33 -0700 (PDT)
Message-ID: <20151011.053333.542722483107870465.davem@davemloft.net>
References: <1444321193-26486-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbJKMRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 08:17:39 -0400
In-Reply-To: <1444321193-26486-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu,  8 Oct 2015 18:19:53 +0200

> This is a clone of commit 2ab957492d13b ("ip_forward: Drop frames with
> attached skb->sk") for ipv6.
> 
> This commit has exactly the same reasons as the above mentioned commit,
> namely to prevent panics during netfilter reload or a misconfigured stack.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Also applied, thanks Hannes.
