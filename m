From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: convert MLDv2 Query MRC into
 msecs_to_jiffies for max_delay
Date: Fri, 30 Aug 2013 17:57:14 -0400 (EDT)
Message-ID: <20130830.175714.561284513170389446.davem@davemloft.net>
References: <1377813305-11058-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linus.luessing@web.de,
	hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870Ab3H3V5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:57:16 -0400
In-Reply-To: <1377813305-11058-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 29 Aug 2013 23:55:05 +0200

> While looking into MLDv1/v2 code, I noticed that bridging code does
> not convert it's max delay into jiffies for MLDv2 messages as we do
> in core IPv6' multicast code.
> 
> RFC3810, 5.1.3. Maximum Response Code says:
> 
>   The Maximum Response Code field specifies the maximum time allowed
>   before sending a responding Report. The actual time allowed, called
>   the Maximum Response Delay, is represented in units of milliseconds,
>   and is derived from the Maximum Response Code as follows: [...]
> 
> As we update timers that work with jiffies, we need to convert it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.
