From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: Netpoll checksum issue
Date: Thu, 20 Apr 2006 07:34:48 +1000
Message-ID: <20060419213448.GB18997@gondor.apana.org.au>
References: <20060419101557.30ac8461@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Aubrey <aubreylee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42500 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751097AbWDSVev
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 17:34:51 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060419101557.30ac8461@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Date: Thu, 20 Apr 2006 00:22:16 +0800
> From: Aubrey <aubreylee@gmail.com>
> Newsgroups: linux.dev.kernel
> Subject: Netpoll checksum issue
> 
> I'm porting my network driver from 2.6.12 to 2.6.16. It almostly work
> without any change, except the netpoll mode. When I use kgdb to debug
> kernel, gdb client can not establish the connection with gdb server.
> Then I digged into the code, and I found in the routine "__netpoll_rx"
> in the file "net/core/netpoll.c", the "checksum_udp" call always
> failed, but it works on 2.6.12.
> Could you please give me some suggestions?

Is your driver open source?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
