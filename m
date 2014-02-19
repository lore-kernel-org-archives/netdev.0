From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] pcnet32: fix reallocation error
Date: Wed, 19 Feb 2014 14:59:43 -0500 (EST)
Message-ID: <20140219.145943.1938903560872720656.davem@davemloft.net>
References: <1392699466.4020.27.camel@Linux>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pcnet32@frontier.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754877AbaBST7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:59:45 -0500
In-Reply-To: <1392699466.4020.27.camel@Linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Fry <pcnet32@frontier.com>
Date: Mon, 17 Feb 2014 20:57:46 -0800

> pcnet32_realloc_rx_ring() only worked on the first log2 number of
> entries in the receive ring instead of the all the entries.
> Replaced "1 << size" with more descriptive variable.
> This is my original bug from 2006.  Found while testing another problem.
> Tested on 79C972 and 79C976.
> 
> Signed-off-by: Don Fry <pcnet32@frontier.com>

Applied.
