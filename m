From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] htb: reorder struct htb_class fields for
 performance
Date: Thu, 13 Jun 2013 17:17:25 -0700 (PDT)
Message-ID: <20130613.171725.167784637364785392.davem@davemloft.net>
References: <1371135510.3252.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609Ab3FNARZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:17:25 -0400
In-Reply-To: <1371135510.3252.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Jun 2013 07:58:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> htb_class structures are big, and source of false sharing on SMP.
> 
> By carefully splitting them in two parts, we can improve performance.
> 
> I got 9 % performance increase on a 24 threads machine, with 200
> concurrent netperf in TCP_RR mode, using a HTB hierarchy of 4 classes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com> 

Applied, thanks Eric.
