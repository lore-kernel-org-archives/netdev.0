From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Thu, 10 Jan 2008 22:36:23 +0000
Message-ID: <20080110223623.3a925f57@lxorguk.ukuu.org.uk>
References: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
	<alpine.BSF.1.00.0801092031290.35527@pkunk.americas.sgi.com>
	<alpine.BSF.1.00.0801101554100.52456@pkunk.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Brent Casavant <bcasavan@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:50182 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753242AbYAJWjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 17:39:08 -0500
In-Reply-To: <alpine.BSF.1.00.0801101554100.52456@pkunk.americas.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> and the parallel portions/comments in unix_dgram_recvmsg(),
> it looks like there's been a lot of uncertainty as to how
> file descriptor passing should be handled durning MSG_PEEK
> operations.  To quote:

The specs basically don't answer the question. What is critical is that
the behaviour does not change compared with older Linux releases.

