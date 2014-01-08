From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Tue, 07 Jan 2014 22:43:57 -0500 (EST)
Message-ID: <20140107.224357.1577838150943921013.davem@davemloft.net>
References: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbaAHDoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 22:44:03 -0500
In-Reply-To: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 8 Jan 2014 10:56:40 +0800

> Fix below sparse warning:
> 
> net/ipv6/xfrm6_state.c:66:26: error: cannot size expression
 ...
> -	memset(count, 0, sizeof(count));
> +	memset(count, 0, sizeof(int) * maxclass);

I think the fix belongs in sparse, making it respect these two expressions
as equivalent.
