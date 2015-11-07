From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: use kmalloc() than kmalloc_array().
Date: Sat, 07 Nov 2015 14:21:35 -0500 (EST)
Message-ID: <20151107.142135.2089779750111099230.davem@davemloft.net>
References: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1446922207.17135.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, edumazet@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbbKGTVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 14:21:39 -0500
In-Reply-To: <1446922207.17135.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 07 Nov 2015 10:50:07 -0800

> I do not feel we should go back to kmalloc() just because
> vmalloc_array() does not exist yet.

Agreed.
