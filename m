From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: syncookies: reduce mss table to four values
Date: Wed, 28 Aug 2013 18:22:00 -0400 (EDT)
Message-ID: <20130828.182200.304733834519582086.davem@davemloft.net>
References: <1377453242-4773-1-git-send-email-fw@strlen.de>
	<1377453242-4773-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbohac@suse.cz
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636Ab3H1WWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 18:22:02 -0400
In-Reply-To: <1377453242-4773-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 25 Aug 2013 19:54:02 +0200

> Halve mss table size to make blind cookie guessing more difficult.
> This is sad since the tables were already small, but there
> is little alternative except perhaps adding more precise mss information
> in the tcp timestamp.  Timestamps are unfortunately not ubiquitous.
> 
> Guessing all possible cookie values still has 8-in 2**32 chance.
> 
> Reported-by: Jakob Lell <jakob@jakoblell.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

It seems you've decided to retain different sets of entries in these
two tables.

It is not at all obvious to me if this was intentional, and if so
then why such a choice was made.

Please clarify this.

Thank you.
