From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: restore "overhead xxx" handling
Date: Sun, 02 Jun 2013 22:23:07 -0700 (PDT)
Message-ID: <20130602.222307.1783476955623229368.davem@davemloft.net>
References: <1370217305.24311.104.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, j.vimal@gmail.com,
	jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab3FCFXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 01:23:09 -0400
In-Reply-To: <1370217305.24311.104.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 Jun 2013 16:55:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 56b765b79 ("htb: improved accuracy at high rates")
> broke the "overhead xxx" handling, as well as the "linklayer atm"
> attribute.
> 
> tc class add ... htb rate X ceil Y linklayer atm overhead 10
> 
> This patch restores the "overhead xxx" handling, for htb, tbf
> and act_police
> 
> The "linklayer atm" thing needs a separate fix.
> 
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
