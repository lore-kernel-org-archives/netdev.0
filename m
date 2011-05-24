From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 13:18:16 -0400 (EDT)
Message-ID: <20110524.131816.2260767241494258794.davem@davemloft.net>
References: <1306223101.2638.43.camel@edumazet-laptop>
	<20110524.035801.1555795213632087107.davem@davemloft.net>
	<20110524074355.422e12f9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, joe@perches.com, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, tgraf@infradead.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1EXRT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:19:59 -0400
In-Reply-To: <20110524074355.422e12f9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 24 May 2011 07:43:55 -0700

> Couldn't the pointer be replaced by a socket index?

Well, it's a pointer exactly so we don't have to index into a table.
