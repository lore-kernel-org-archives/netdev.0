From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Fri, 15 Dec 2006 13:24:32 +1100
Message-ID: <E1Gv2kS-0002QY-00@gondolin.me.apana.org.au>
References: <87mz5qnf5q.fsf@sycorax.lbl.gov>
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4585 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965007AbWLOCYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 21:24:52 -0500
To: romosan@sycorax.lbl.gov (Alex Romosan)
In-Reply-To: <87mz5qnf5q.fsf@sycorax.lbl.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alex Romosan <romosan@sycorax.lbl.gov> wrote:
 /** does the HW need to evaluate checksum for TCP or UDP packets?
> if (pMessage->ip_summed == CHECKSUM_HW)
> 
> maybe this needs to be replace with CHECKSUM_PARTIAL. the second one
> 
> /** TCP checksum offload
> if ((pSKPacket->pMbuf->ip_summed == CHECKSUM_HW) &&
> (SetOpcodePacketFlag == SK_TRUE)
> 
> i wonder if this is supposed to be CHECKSUM_COMPLETE

The rule of thumb is that it's COMPLETE for RX, and PARTIAL for TX.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
