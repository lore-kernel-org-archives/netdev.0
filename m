From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: remove duplicate NULL check
Date: Thu, 17 May 2012 04:48:37 -0400 (EDT)
Message-ID: <20120517.044837.2251136486222452174.davem@davemloft.net>
References: <20120517065102.GC14660@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, dhowells@redhat.com,
	ext-phil.2.carmody@nokia.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349Ab2EQIss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 04:48:48 -0400
In-Reply-To: <20120517065102.GC14660@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 17 May 2012 09:51:02 +0300

> We test both "!skb_out" and "skb_out" here which is duplicative and
> causes a static checker warning.  I considered that the intent might
> have been to test "skb_in" but that's a valid pointer here.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
