From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops in 2.6.22.1: skb_copy_and_csum_datagram_iovec()
Date: Wed, 22 Aug 2007 15:40:32 +0800
Message-ID: <E1INkpM-00007x-00@gondolin.me.apana.org.au>
References: <46CB453B.5040005@redhat.com>
Cc: netdev@vger.kernel.org
To: cebbert@redhat.com (Chuck Ebbert), neilb@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2533 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751414AbXHVHkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 03:40:45 -0400
In-Reply-To: <46CB453B.5040005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert <cebbert@redhat.com> wrote:
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=253290
> 
> 18:57:54 osama kernel:  [<c05be67f>] kernel_recvmsg+0x31/0x40
> 18:57:54 osama kernel:  [<e0bc52d4>] svc_udp_recvfrom+0x114/0x368 [sunrpc]

svc_udp_recvfrom is calling kernel_recvmsg with iov == NULL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
