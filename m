From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -next 0/3] tcp: honour SO_BINDTODEVICE for TW_RST
 case too
Date: Tue, 22 Dec 2015 17:03:25 -0500 (EST)
Message-ID: <20151222.170325.1441695270139322465.davem@davemloft.net>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933333AbbLVWD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 17:03:26 -0500
In-Reply-To: <1450729766-14926-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 21 Dec 2015 21:29:23 +0100

> This is V2, this time as a small series since I followed Erics advice
> to split this into smaller chunks, I hope this makes it easier to
> review.
> 
> First patch adds inet_sk_transparent helper.
> Second patch contains an if/else swap that I split from the
> original TW_RST v1 one.
> Third patch is the actual change without the superfluous sock_net change.

Looks good, series applied, thanks Florian!
