From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: fq: more robust memory allocation
Date: Sat, 14 Dec 2013 08:31:15 -0800
Message-ID: <1387038675.19078.192.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386894912.19078.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131214.011942.1693344941253042499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33898 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab3LNQbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 11:31:17 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so1254703pab.0
        for <netdev@vger.kernel.org>; Sat, 14 Dec 2013 08:31:17 -0800 (PST)
In-Reply-To: <20131214.011942.1693344941253042499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-12-14 at 01:19 -0500, David Miller wrote:

> Eric, please make a "fq_alloc()" which does this:
> 
> 	x = kmalloc;
> 	if (!x)
> 		x = vmalloc;
> 
> dance, in order to complement fq_free().

Sure, will do, thanks !
