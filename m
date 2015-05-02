From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netlink socket leaks
Date: Sat, 2 May 2015 10:05:34 +0800
Message-ID: <20150502020534.GA9633@gondor.apana.org.au>
References: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com>
 <CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrey Wagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33576 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbEBCFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 22:05:37 -0400
Content-Disposition: inline
In-Reply-To: <CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2015 at 02:31:09AM +0300, Andrey Wagin wrote:
>
> A socket leaks if it is released by sk_release_kernel(). The problem
> is that netlink_insert() and netlink_remove() is called when a socket
> has different values of sk->sk_net.

Thanks for catching this! Let me look into this to see if we
can still safely dereference the namespace at this point.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
