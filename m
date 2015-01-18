From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] net: replace br_fdb_external_learn_*
 calls with switchdev notifier events
Date: Sun, 18 Jan 2015 00:24:16 -0500 (EST)
Message-ID: <20150118.002416.779228776497961683.davem@davemloft.net>
References: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
	<1421362177-10719-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, sfeldma@gmail.co,
	stephen@networkplumber.org, linus.luessing@web.de, tgraf@suug.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbARFYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:24:18 -0500
In-Reply-To: <1421362177-10719-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 15 Jan 2015 23:49:37 +0100

> This patch benefits from newly introduced switchdev notifier and uses it
> to propagate fdb learn events from rocker driver to bridge. That avoids
> direct function calls and possible use by other listeners (ovs).
> 
> Suggested-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
