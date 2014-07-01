From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix possible panic under memory stress
Date: Tue, 01 Jul 2014 12:20:48 -0700 (PDT)
Message-ID: <20140701.122048.2126140839754660400.davem@davemloft.net>
References: <1403768642.374.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, walken@google.com, ariel.elior@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbaGATUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 15:20:49 -0400
In-Reply-To: <1403768642.374.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Jun 2014 00:44:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While it is legal to kfree(NULL), it is not wise to use :
> put_page(virt_to_head_page(NULL))
> 
>  BUG: unable to handle kernel paging request at ffffeba400000000
>  IP: [<ffffffffc01f5928>] virt_to_head_page+0x36/0x44 [bnx2x]
> 
> Reported-by: Michel Lespinasse <walken@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ariel Elior <ariel.elior@qlogic.com>
> Fixes: d46d132cc021 ("bnx2x: use netdev_alloc_frag()")
> ---
> This is a stable candidate, bug added in linux-3.8

Applied and queued up for -stable, thanks.
