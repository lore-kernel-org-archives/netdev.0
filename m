From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] random32: add __init prefix to
 prandom_start_seed_timer
Date: Thu, 14 Nov 2013 16:06:55 -0500 (EST)
Message-ID: <20131114.160655.49204055657873044.davem@davemloft.net>
References: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097Ab3KNVG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:06:58 -0500
In-Reply-To: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 12 Nov 2013 23:45:41 +0100

> We only call that in functions annotated with __init, so add __init
> prefix in prandom_start_seed_timer() as well, so that the kernel can
> make use of this hint and we can possibly free up resources after it's
> usage. And since it's an internal function rename it to
> __prandom_start_seed_timer().
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
