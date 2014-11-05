From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Wed, 05 Nov 2014 15:51:40 -0500 (EST)
Message-ID: <20141105.155140.1110198452648637549.davem@davemloft.net>
References: <20141104.222727.275422581392488793.davem@davemloft.net>
	<20141105035536.GO7996@ZenIV.linux.org.uk>
	<20141105041231.GP7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbaKEUvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:51:42 -0500
In-Reply-To: <20141105041231.GP7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 5 Nov 2014 04:12:32 +0000

> On Wed, Nov 05, 2014 at 03:55:36AM +0000, Al Viro wrote:
>> What do you think of the trick with user_msghdr, BTW?
> 
> 	PS: where do you prefer the branches to be based off?
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net#master, mainline,
> something else?  I can certainly do that as patches over email, the
> question is what's best used as base...  FWIW, the analysis I've posted
> was in 3.18-rc3 and it looks like it ought to be valid in net#master
> as well.

Let's work against net-next, ie:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next#master

I can integrate, your, mine, and Herbert's changes all into the same
place.

Thanks.
