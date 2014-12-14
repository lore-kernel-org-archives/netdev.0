From: David Miller <davem@davemloft.net>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Sat, 13 Dec 2014 23:38:57 -0500 (EST)
Message-ID: <20141213.233857.536672902237894179.davem@davemloft.net>
References: <20141212.213313.1419808296502891420.davem@davemloft.net>
	<20141213032500.GH22149@ZenIV.linux.org.uk>
	<20141213045133.GI22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	dmitry.tarnyagin@lockless.no
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaLNEjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 23:39:04 -0500
In-Reply-To: <20141213045133.GI22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 13 Dec 2014 04:51:33 +0000

> On Sat, Dec 13, 2014 at 03:25:00AM +0000, Al Viro wrote:
>> 	    msg->msg_iter.type == KVEC_ITER &&
> 
> ITER_IOVEC, that is.  And that way it even works...  Are you OK with the
> commit below?

No objection, looks perfectly fine.
