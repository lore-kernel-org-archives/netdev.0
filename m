From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 2/2] tcp: change TCP_ECN prefixes to lower case
Date: Mon, 29 Sep 2014 14:41:51 -0400 (EDT)
Message-ID: <20140929.144151.516262314020839655.davem@davemloft.net>
References: <1411988910-23710-1-git-send-email-fw@strlen.de>
	<1411988910-23710-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaI2Slx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:41:53 -0400
In-Reply-To: <1411988910-23710-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 29 Sep 2014 13:08:30 +0200

> Suggested by Stephen. Also drop inline keyword and let compiler decide.
> 
> gcc 4.7.3 decides to no longer inline tcp_ecn_check_ce, so split it up.
> The actual evaluation is not inlined anymore while the ECN_OK test is.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
