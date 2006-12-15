From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 19:22:18 -0800
Message-ID: <20061214192218.35a7f8e1@localhost.localdomain>
References: <87mz5qnf5q.fsf@sycorax.lbl.gov>
	<E1Gv2kS-0002QY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romosan@sycorax.lbl.gov (Alex Romosan), netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:55623 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbWLODXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 22:23:01 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Gv2kS-0002QY-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Dec 2006 13:24:32 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Alex Romosan <romosan@sycorax.lbl.gov> wrote:
>  /** does the HW need to evaluate checksum for TCP or UDP packets?
> > if (pMessage->ip_summed == CHECKSUM_HW)
> > 
> > maybe this needs to be replace with CHECKSUM_PARTIAL. the second one
> > 
> > /** TCP checksum offload
> > if ((pSKPacket->pMbuf->ip_summed == CHECKSUM_HW) &&
> > (SetOpcodePacketFlag == SK_TRUE)
> > 
> > i wonder if this is supposed to be CHECKSUM_COMPLETE
> 
> The rule of thumb is that it's COMPLETE for RX, and PARTIAL for TX.
> 
> Cheers,

I have a fixed up version of the vendor driver, I'll repackage it tomorrow.
