From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: make fib_detect_death static
Date: Sat, 28 Dec 2013 01:21:42 -0500 (EST)
Message-ID: <20131228.012142.2197039481840374168.davem@davemloft.net>
References: <20131227121053.5f3445ac@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab3L1GVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:21:43 -0500
In-Reply-To: <20131227121053.5f3445ac@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 27 Dec 2013 12:10:53 -0800

> -int fib_detect_death(struct fib_info *fi, int order,
> +static int fib_detect_death(struct fib_info *fi, int order,
>  		     struct fib_info **last_resort, int *last_idx, int dflt)

Please reindent the args.
