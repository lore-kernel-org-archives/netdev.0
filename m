From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] arch_fast_hash: avoid indirect function calls
 and implement hash in asm
Date: Tue, 09 Dec 2014 14:39:09 -0500 (EST)
Message-ID: <20141209.143909.1690366723140906216.davem@davemloft.net>
References: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	jay.vosburgh@canonical.com, tgraf@suug.ch, dborkman@redhat.com,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbaLITjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:39:12 -0500
In-Reply-To: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu,  4 Dec 2014 14:08:50 +0100

> By default the arch_fast_hash hashing function pointers are initialized
> to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
> updated to the CRC32 ones. This dispatching scheme incurs a function
> pointer lookup and indirect call for every hashing operation.
> 
> To keep the number of clobbered registers short the hashing primitives
> are implemented in assembler. This makes it easier to do the dispatch
> by alternative_call.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Jay Vosburgh <jay.vosburgh@canonical.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I'm not applying this, I want this whole facility removed instead.
