From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 09:13:22 -0500
Message-ID: <20110228141322.GF9763@canuck.infradead.org>
References: <20110225.112019.48513284.davem@davemloft.net>
 <20110226005718.GA19889@gondor.apana.org.au>
 <20110227110205.GE9763@canuck.infradead.org>
 <20110227110614.GA6246@gondor.apana.org.au>
 <20110228113659.GA20726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47249 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111Ab1B1ONc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 09:13:32 -0500
Content-Disposition: inline
In-Reply-To: <20110228113659.GA20726@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 07:36:59PM +0800, Herbert Xu wrote:
> But please do test them heavily, especially if you have an AMD
> NUMA machine as that's where scalability problems really show
> up.  Intel tends to be a lot more forgiving.  My last AMD machine
> blew up years ago :)

This is just a preliminary test result and not 100% reliable
because half through the testing the machine reported memory
issues and disabled a DIMM before booting the tested kernels.

Nevertheless, bind 9.7.3:

2.6.38-rc5+: 62kqps
2.6.38-rc5+ w/ Herbert's patch: 442kqps

This is on a 2 NUMA Intel Xeon X5560 @ 2.80GHz with 16 cores

Again, this number is not 100% reliably but clearly shows that
the concept of the patch is working very well.

Will test Herbert's patch on the machine that did 650kqps with
SO_REUSEPORT and also on some AMD machines.
