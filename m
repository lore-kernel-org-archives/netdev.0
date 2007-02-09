From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Sat, 10 Feb 2007 07:12:21 +1100
Message-ID: <E1HFc6X-0006n7-00@gondolin.me.apana.org.au>
References: <7478.1171000672@mdt.dhcp.pit.laurelnetworks.com>
Cc: netdev@vger.kernel.org
To: maccetta@laurelnetworks.com (Mike Accetta)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1250 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992800AbXBIUMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 15:12:34 -0500
In-Reply-To: <7478.1171000672@mdt.dhcp.pit.laurelnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Accetta <maccetta@laurelnetworks.com> wrote:
> 
> Obviously the code believes it can assume that there are always multiple
> sk_buff's in the chain.  The stack trace seems to implicate iptables in
> the scenario (twice) if that means anything.  Any ideas about what may
> be going wrong here?  There is indeed a private module loaded at the time
> but it does no networking and I doubt it is the culprit.

Yeah we should never get here if we only have one segment.
Could you get it to print out the value of skb->gso_*?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
