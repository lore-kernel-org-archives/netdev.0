From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: fix lockdep splat in ppp_dev_uninit()
Date: Fri, 25 Sep 2015 12:38:49 -0700 (PDT)
Message-ID: <20150925.123849.2051432696335836688.davem@davemloft.net>
References: <7cd953e3577a36cbd942c3635ac55e4f2975bcaa.1443091841.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, sedat.dilek@gmail.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932891AbbIYTiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 15:38:50 -0400
In-Reply-To: <7cd953e3577a36cbd942c3635ac55e4f2975bcaa.1443091841.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 24 Sep 2015 12:54:01 +0200

> ppp_dev_uninit() locks all_ppp_mutex while under rtnl mutex protection.
> ppp_create_interface() must then lock these mutexes in that same order
> to avoid possible deadlock.
 ...
> Fixes: 8cb775bc0a34 ("ppp: fix device unregistration upon netns deletion")
> Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
