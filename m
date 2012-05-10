From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net] 6lowpan: add missing pskb_may_pull() check
Date: Thu, 10 May 2012 12:28:06 -0400 (EDT)
Message-ID: <20120510.122806.257965866445295921.davem@davemloft.net>
References: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
	<1336656659.12504.153.camel@edumazet-glaptop>
	<CAJmB2rCo0CfHP992Jix=mtshSS-wn92rf+3yg-ZK1_KLkXKRGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab2EJQ2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 12:28:09 -0400
In-Reply-To: <CAJmB2rCo0CfHP992Jix=mtshSS-wn92rf+3yg-ZK1_KLkXKRGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Thu, 10 May 2012 18:05:46 +0400

> Using BUG() macro I just want to indicate that something in the bottom
> of the stack went terribly wrong and you must check your code for
> bugs..

Then you should do something like:

	if (WARN_ON_ONCE(!pskb_may_pull(...))) {
		appropriate_error_handling();
		return;
	}

instead.
