From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 -next 2/2] tcp: syncookies: reduce mss table to four
 values
Date: Tue, 24 Sep 2013 10:40:26 -0400 (EDT)
Message-ID: <20130924.104026.1557379333541367159.davem@davemloft.net>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
	<1379709176-1625-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab3IXOk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 10:40:28 -0400
In-Reply-To: <1379709176-1625-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 20 Sep 2013 22:32:56 +0200

> Halve mss table size to make blind cookie guessing more difficult.
> This is sad since the tables were already small, but there
> is little alternative except perhaps adding more precise mss information
> in the tcp timestamp.  Timestamps are unfortunately not ubiquitous.
> 
> Guessing all possible cookie values still has 8-in 2**32 chance.
> 
> Reported-by: Jakob Lell <jakob@jakoblell.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.

Thanks for following up on all of my feedback.
