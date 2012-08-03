From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 03 Aug 2012 01:52:43 -0700 (PDT)
Message-ID: <20120803.015243.1041602621154758483.davem@davemloft.net>
References: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab2HCIwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 04:52:44 -0400
In-Reply-To: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Fri,  3 Aug 2012 01:43:10 -0600

> It is always wrong to write 'return (...)'.

In your imagination.

> After removal, realign the code where necessary.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

> -	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> -		(IN4_ADDR_HSIZE - 1));
> +	return (val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> +	       (IN4_ADDR_HSIZE - 1);

Those parenthesis are there to make the evaluation order and
grouping explicit.

The other ones you changed are wrong for similar reasons.

I absolutely am not applying patches like this.
