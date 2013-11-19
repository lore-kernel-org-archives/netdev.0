From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xfrm: Release dst if this dst is improper for vti
 tunnel
Date: Tue, 19 Nov 2013 15:51:25 -0500 (EST)
Message-ID: <20131119.155125.1331712714979376193.davem@davemloft.net>
References: <1384851208-30353-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, saurabh.mohan@brocade.com,
	netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab3KSUva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 15:51:30 -0500
In-Reply-To: <1384851208-30353-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 19 Nov 2013 16:53:28 +0800

> After searching rt by the vti tunnel dst/src parameter,
> if this rt has neither attached to any transformation
> nor the transformation is not tunnel oriented, this rt
> should be released back to ip layer.
> 
> otherwise causing dst memory leakage.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Good catch, applied and queued up for -stable, thanks!
