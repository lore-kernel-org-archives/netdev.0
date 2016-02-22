From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v4 0/3] IPvlan misc patches
Date: Sun, 21 Feb 2016 22:45:16 -0500 (EST)
Message-ID: <20160221.224516.345929630999490010.davem@davemloft.net>
References: <1456025482-30203-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbcBVDpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 22:45:18 -0500
In-Reply-To: <1456025482-30203-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Sat, 20 Feb 2016 19:31:22 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> This is a collection of unrelated patches for IPvlan driver.
> a. crub_skb() changes are added to ensure that the packets hit the
> NF_HOOKS in masters' ns in L3 mode.
> b. u16 change is bug fix while
> c. the third patch is to group tx/rx variables in single cacheline

I applied this series, but this is an extremely poor quality
submission.

You don't capitalize sentences, particularly in the Subject lines
of your patches.

Your descriptions are quite poor.  You say here that patch 'c' is
about grouping things for cache locality but that patch does a lot
of completely unrelated things too.

I really think you put very little effort into the formatting,
descriptions, grouping, and general layout of this patch series.  And
it shows.
