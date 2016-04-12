From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3] net: sched: do not requeue a NULL skb
Date: Tue, 12 Apr 2016 09:23:47 -0700
Message-ID: <1460478227.6473.590.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460443552-26710-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com,
	Lars Persson <larper@axis.com>
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34609 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756497AbcDLQXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 12:23:50 -0400
In-Reply-To: <1460443552-26710-1-git-send-email-larper@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-12 at 08:45 +0200, Lars Persson wrote:
> A failure in validate_xmit_skb_list() triggered an unconditional call
> to dev_requeue_skb with skb=NULL. This slowly grows the queue
> discipline's qlen count until all traffic through the queue stops.

> 
> Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
> Signed-off-by: Lars Persson <larper@axis.com>
> ---


Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
