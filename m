From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Wed, 5 Nov 2014 04:12:32 +0000
Message-ID: <20141105041231.GP7996@ZenIV.linux.org.uk>
References: <20141104144258.GA14743@gondor.apana.org.au>
 <20141104151353.GG7996@ZenIV.linux.org.uk>
 <20141105022251.GA19136@gondor.apana.org.au>
 <20141104.222727.275422581392488793.davem@davemloft.net>
 <20141105035536.GO7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43116 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbaKEEMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 23:12:36 -0500
Content-Disposition: inline
In-Reply-To: <20141105035536.GO7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 03:55:36AM +0000, Al Viro wrote:
> What do you think of the trick with user_msghdr, BTW?

	PS: where do you prefer the branches to be based off?
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net#master, mainline,
something else?  I can certainly do that as patches over email, the
question is what's best used as base...  FWIW, the analysis I've posted
was in 3.18-rc3 and it looks like it ought to be valid in net#master
as well.
