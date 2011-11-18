From: David Miller <davem@davemloft.net>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Fri, 18 Nov 2011 15:26:50 -0500 (EST)
Message-ID: <20111118.152650.665723216724325647.davem@davemloft.net>
References: <1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321551536.2751.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321632128.3277.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, famzah@icdsoft.com, netdev@vger.kernel.org,
	segoon@openwall.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab1KRU1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 15:27:09 -0500
In-Reply-To: <1321632128.3277.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Nov 2011 17:02:08 +0100

> David, unless I missed something, we should revert commit f39925dbde77
> ipv4: Cache learned redirect information in inetpeer.)
> 
> With following patch, redirects now work for me.

Yes, it doesn't work very well... sigh.

I've applied your patch and queued it up for stable.

Long term we need a different scheme for redirects.

Thanks!
