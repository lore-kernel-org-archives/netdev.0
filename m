From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] tcp: listener refactoring preparations
Date: Tue, 29 Sep 2015 17:01:42 -0700 (PDT)
Message-ID: <20150929.170142.2055182484739344465.davem@davemloft.net>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbI3ABn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 20:01:43 -0400
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 29 Sep 2015 07:42:38 -0700

> This patch series makes changes to TCP/DCCP stacks so that
> we can switch listener code to lockless mode.
> 
> This is done by marking const the listener socket in all
> appropriate paths.
> 
> FastOpen code had to be changed to not dynamically allocate
> a very small structure to make code simpler for following changes.

Series applied, thanks Eric.
