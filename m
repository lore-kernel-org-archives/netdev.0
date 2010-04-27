From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 09:37:11 -0400
Message-ID: <4BD6E887.3000804@athenacr.com>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>	<1272302434.19143.76.camel@edumazet-laptop>	<q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com> <20100426.110432.104061817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:57027 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750830Ab0D0NhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 09:37:17 -0400
In-Reply-To: <20100426.110432.104061817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> How damn hard is it to add two 16-bit ports to the hash regardless of
> protocol?
>   
Come to think of it, for UDP the hash must ignore
the srcport and srcaddr, because a single bound
socket is going to wildcard both those fields.

So the best we can hope for is for the hash to
include destport and destaddr? From looking at
my BCM5709's multiq behavior, I think broadcom's
hash includes the destaddr but not the destport.

