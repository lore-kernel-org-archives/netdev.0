From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH/RFC] Use of uninitialized data in udp_recvmsg().
Date: Tue, 06 Mar 2007 08:57:42 +1100
Message-ID: <E1HOLBe-000660-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0703051212350.21570@jchow-amax.eng.vmware.com>
Cc: netdev@vger.kernel.org
To: jchow@vmware.com (Jim Chow)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3985 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933669AbXCEV5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 16:57:50 -0500
In-Reply-To: <Pine.LNX.4.64.0703051212350.21570@jchow-amax.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jim Chow <jchow@vmware.com> wrote:
> After inspection of some networking code, it seems there is a use of
> uninitialized data in udp_recvmsg(),
> linux-2.6.20.1/net/ipv4/udp.c:843, while testing msg->msg_flags (see
> the backtrace below).  It looks like sys_recvfrom() is not

msg_flags is set on return and its initial value is not used.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
