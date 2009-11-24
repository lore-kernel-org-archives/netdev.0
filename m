From: Patrick McHardy <kaber@trash.net>
Subject: Re: macvlan: fix gso_max_size setting
Date: Tue, 24 Nov 2009 11:57:29 +0100
Message-ID: <4B0BBC19.109@trash.net>
References: <4B0A64E2.8090203@trash.net> <20091123.101013.40629093.davem@davemloft.net> <4B0B087B.3020000@trash.net> <20091123.142207.14190542.davem@davemloft.net> <4B0B0DA1.7010403@trash.net> <20091124010817.GB13660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65298 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbZKXK5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 05:57:24 -0500
In-Reply-To: <20091124010817.GB13660@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Nov 23, 2009 at 11:33:05PM +0100, Patrick McHardy wrote:
>> Perhaps we should simply fall back to software in that case.
>> Compile tested only.
> 
> Sure.
> 
> Since ixgbe appears to be the only driver in our entire tree
> that has this limitation, I think it might make more sense to
> move this special-case check into it and get it to do software
> GSO just like tg3 does for a few other cases that the hardware
> can't handle.

Sure, that would also be fine. I'll leave that for the Intel
guys however :)
