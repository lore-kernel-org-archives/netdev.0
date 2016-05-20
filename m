From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: suppress warnings on dev_alloc_skb
Date: Fri, 20 May 2016 19:59:01 -0400 (EDT)
Message-ID: <20160520.195901.227587056831866852.davem@davemloft.net>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
	<1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.duyck@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbcETX7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:59:02 -0400
In-Reply-To: <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 19 May 2016 11:30:54 -0400

> Noticed an allocation failure in a network driver the other day on a 32 bit
> system:
 ...
> Thought that perhaps the big splat in the logs wasn't really necessecary, as
> all call sites for dev_alloc_skb:
> 
> a) check the return code for the function
> 
> and
> 
> b) either print their own error message or have a recovery path that makes the
> warning moot.
> 
> Fix it by modifying dev_alloc_pages to pass __GFP_NOWARN as a gfp flag to
> suppress the warning
> 
> applies to the net tree
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
