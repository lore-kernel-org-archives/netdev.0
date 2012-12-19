From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL net-next 01/17] ndisc: Fix size calculation for
 headers.
Date: Tue, 18 Dec 2012 16:23:38 -0800 (PST)
Message-ID: <20121218.162338.1594192050394527214.davem@davemloft.net>
References: <50CF84A5.7030706@linux-ipv6.org>
	<50D04AD4.8010908@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967Ab2LSAXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 19:23:39 -0500
In-Reply-To: <50D04AD4.8010908@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 18 Dec 2012 19:52:04 +0900

> We used to allocate MAX_HEADER bytes more than needed but
> reserved hlen only (not MAX_HEADER + hlen) and the MAX_HEADER
> was left behind.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

This change is wrong.

The MAX_HEADER is being used in order to accomodate any
possible encapsulation that may occur.

I'm really disappointed that the very first patch in this series is
buggy, and you didn't even bother to repost the absolutely required
"00/17" email for this series which is where you're supposed to give a
top-level overview of your changes as well as any GIT pull request.
