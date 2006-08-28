From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Mon, 28 Aug 2006 10:16:56 +1000
Message-ID: <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au>
References: <20060827142347.GA20092@ripe.net>
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57096 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751258AbWH1ARM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 20:17:12 -0400
To: cagri@ripe.net (cagri coltekin)
In-Reply-To: <20060827142347.GA20092@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cagri coltekin <cagri@ripe.net> wrote:
> 
> Aug 25 04:03:35 ns kernel: ------------[ cut here ]------------
> Aug 25 04:03:35 ns kernel: kernel BUG at net/ipv6/ip6_output.c:718!
> Aug 25 04:03:35 ns kernel: invalid operand: 0000 [#1]
> Aug 25 04:03:35 ns kernel: SMP 
> Aug 25 04:03:35 ns kernel: Modules linked in: uhci_hcd ehci_hcd ohci_hcd aic7xxx ide_cd
> Aug 25 04:03:35 ns kernel: CPU:    3
> Aug 25 04:03:35 ns kernel: EIP:    0060:[svc_create_socket+189/416]    Not tainted VLI
> Aug 25 04:03:35 ns kernel: EFLAGS: 00010282   (2.6.12.6-ncc-server) 

This is an ancient kernel.  Please really try 2.6.17 instead of just
talking about it (the line number confirms that it is 2.6.12).

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
