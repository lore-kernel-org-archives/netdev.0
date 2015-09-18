From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Initialize table in fib result
Date: Thu, 17 Sep 2015 21:35:15 -0700 (PDT)
Message-ID: <20150917.213515.2090670741708133563.davem@davemloft.net>
References: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergey.senozhatsky.work@gmail.com,
	richard.alpe@ericsson.com, festevam@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbIREfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:35:17 -0400
In-Reply-To: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 16 Sep 2015 10:16:39 -0600

> Sergey, Richard and Fabio reported an oops in ip_route_input_noref. e.g., from Richard:
 ...
> The root cause is use of res.table uninitialized.
> 
> Thanks to Nikolay for noticing the uninitialized use amongst the maze of
> gotos.
> 
> As Nikolay pointed out the second initialization is not required to fix
> the oops, but rather to fix a related problem where a valid lookup should
> be invalidated before creating the rth entry.
> 
> Fixes: b7503e0cdb5d ("net: Add FIB table id to rtable")
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Reported-by: Richard Alpe <richard.alpe@ericsson.com>
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2:
> - clarification in the commit message regarding the second initialization

Applied, thanks.
