From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Mon, 17 Dec 2007 09:26:32 +0800
Message-ID: <20071217012632.GA8475@gondor.apana.org.au>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au> <20071214002209.ac748206.akpm@linux-foundation.org> <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org> <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org> <47656931.1040309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4852 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757591AbXLQB1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 20:27:48 -0500
Content-Disposition: inline
In-Reply-To: <47656931.1040309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2007 at 07:06:41PM +0100, Jarek Poplawski wrote:
>
> It seemed to exist a few days ago:
> http://kerneltrap.org/mailarchive/linux-netdev/2007/12/4/473123
> 
> Btw., I don't know which of the patches: Eric's or yours will be chosen,
> but, IMHO, there is no reason to remove rtnl_trylock(), which can be still
> useful, just like mutex_trylock() is.

Doh! Andrew was too convincing :) I misread the grep result on
in_interrupt.  Of course that function returns true if we're
either in an IRQ handler or have BH off.

I retract what I've said in this thread and continue to oppose
this change without a might_sleep.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
