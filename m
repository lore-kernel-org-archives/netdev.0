From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: fix compile warning in cls_u32
Date: Mon, 22 Sep 2014 16:47:36 -0400 (EDT)
Message-ID: <20140922.164736.1264941726747612883.davem@davemloft.net>
References: <1411418573.26859.157.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979AbaIVUri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:47:38 -0400
In-Reply-To: <1411418573.26859.157.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Sep 2014 13:42:53 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> $ grep CONFIG_CLS_U32_MARK .config
> # CONFIG_CLS_U32_MARK is not set
> 
> net/sched/cls_u32.c: In function 'u32_change':
> net/sched/cls_u32.c:852:1: warning: label 'errout' defined but not used
> [-Wunused-label]
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
