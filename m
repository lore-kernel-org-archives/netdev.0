From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: syncookies: reduce mss table to four values
Date: Tue, 03 Sep 2013 22:32:48 -0400 (EDT)
Message-ID: <20130903.223248.1513014156693130244.davem@davemloft.net>
References: <1378065356-25509-1-git-send-email-fw@strlen.de>
	<1378065356-25509-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab3IDCcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:32:50 -0400
In-Reply-To: <1378065356-25509-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun,  1 Sep 2013 21:55:56 +0200

> Halve mss table size to make blind cookie guessing more difficult.
> This is sad since the tables were already small, but there
> is little alternative except perhaps adding more precise mss information
> in the tcp timestamp.  Timestamps are unfortunately not ubiquitous.
> 
> Guessing all possible cookie values still has 8-in 2**32 chance.
> 
> Reported-by: Jakob Lell <jakob@jakoblell.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Changes since v1:
>  - add comment explaining mss choices

The ipv6 choices are still a complete mystery.

Why do you put a 9000 entry into the ipv6 table and have nothing
similar in the ipv4 table?  Why not mimick the ipv4 values in the ipv6
table, as this is exactly what I would expect to be done here?

You need to add a comment to the ipv6 table explaining things, at the
very least.
