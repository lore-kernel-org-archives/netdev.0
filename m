From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: bpf_jit: fix divide by 0 generation
Date: Wed, 18 Jan 2012 16:04:42 -0500 (EST)
Message-ID: <20120118.160442.2257803552295499142.davem@davemloft.net>
References: <20120118155747.GA4991@linuxace.com>
	<1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326907302.4910.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140Ab2ARVEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 16:04:46 -0500
In-Reply-To: <1326907302.4910.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2012 18:21:42 +0100

> Several problems fixed in this patch :
> 
> 1) Target of the conditional jump in case a divide by 0 is performed
>    by a bpf is wrong.
> 
> 2) Must 'generate' the full function prologue/epilogue at pass=0,
>    or else we can stop too early in pass=1 if the proglen doesnt change.
>    (if the increase of prologue/epilogue equals decrease of all
>     instructions length because some jumps are converted to near jumps)
> 
> 3) Change the wrong length detection at the end of code generation to
>    issue a more explicit message, no need for a full stack trace.
> 
> Reported-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
