From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Wed, 28 Mar 2007 13:09:58 +1000
Message-ID: <E1HWOXu-0000P5-00@gondolin.me.apana.org.au>
References: <4609B80A.6070906@psc.edu>
Cc: jheffner@psc.edu, mhuth@mvista.com, davem@davemloft.net,
	dagriego@gmail.com, netdev@vger.kernel.org
To: jheffner@psc.edu (John Heffner)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2516 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752575AbXC1DKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 23:10:20 -0400
In-Reply-To: <4609B80A.6070906@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner <jheffner@psc.edu> wrote:
> 
> Responding to myself in good form :P  I'll add that there are other ways 
> to do this currently but all I know of are hackish, f.e. using a raw 
> socket to send RST packets to yourself.

While not pretty, it is easy enough to ptrace a process using gdb and
call shutdown(2) on the fd.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
