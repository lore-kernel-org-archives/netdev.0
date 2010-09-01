From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net sched: fix kernel leak in act_police
Date: Wed, 01 Sep 2010 14:29:47 -0700 (PDT)
Message-ID: <20100901.142947.128610236.davem@davemloft.net>
References: <4C7D8E86.6020705@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50443
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755849Ab0IAV3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:29:31 -0400
In-Reply-To: <4C7D8E86.6020705@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Date: Tue, 31 Aug 2010 19:21:42 -0400

>  While reviewing commit 1c40be12f7d8ca1d387510d39787b12e512a7ce8, I
>  audited other users of tc_action_ops->dump for information leaks.
> 
>  That commit covered almost all of them but act_police still had a leak.
> 
>  opt.limit and opt.capab aren't zeroed out before the structure is
>  passed out.
> 
>  This patch uses the C99 initializers to zero everything unused out.
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> Acked-by: Jeff Mahoney <jeffm@suse.com>

Applied.
