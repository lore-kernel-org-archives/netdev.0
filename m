From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enable automatic module loading for l2tp_ppp
Date: Wed, 21 Mar 2012 22:15:46 -0400 (EDT)
Message-ID: <20120321.221546.1119411477291923638.davem@davemloft.net>
References: <20120321000121.GA3133@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932369Ab2CVCP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 22:15:58 -0400
In-Reply-To: <20120321000121.GA3133@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 20 Mar 2012 20:01:21 -0400

> When L2TP is configured as a module, requests for L2TP sockets do not result
> in the l2tp_ppp module being loaded.  Fix this by adding the appropriate
> MODULE_ALIAS to be recognized by pppox's request_module() call.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Please start adding proper subsystem/driver prefixes to your
Subject lines when submitting patches, I'm getting tired of
continually having to add them for you.  For this patch
"l2tp: " would have been appropriate.

Applied, thanks.
