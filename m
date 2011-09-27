From: David Miller <davem@davemloft.net>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Tue, 27 Sep 2011 16:08:04 -0400 (EDT)
Message-ID: <20110927.160804.528213323197711241.davem@davemloft.net>
References: <20110927200328.GA22678@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab1I0UIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 16:08:07 -0400
In-Reply-To: <20110927200328.GA22678@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 27 Sep 2011 16:03:28 -0400

> A user just reported this on a fairly old kernel (running the latest -longterm patch).
> I had a look through net/core/skbuff.c since 2.6.35, and didn't see anything obvious.
> Does this look familiar to anyone ? 

I would say that something far outside of __pskb_pull_tail() is corrupting the
SKB state.  He has a bunch of netfilter stuff loaded so the possibilities are
endless :-)

Any chance to figure out exactly what NULL dereference happens inside of
__pskb_pull_tail()?
