From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Fri, 16 May 2008 11:28:32 +0800
Message-ID: <20080516032832.GA6745@gondor.apana.org.au>
References: <20080507130548.GA26977@gondor.apana.org.au> <20080508032208.GA401@gondor.apana.org.au> <20080507.202606.242037993.davem@davemloft.net> <200805161201.48835.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, ron.rindjunsky@intel.com, tomasw@gmail.com,
	ivdoorn@gmail.com, peter.p.waskiewicz.jr@intel.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35253 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757638AbYEPD2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 23:28:55 -0400
Content-Disposition: inline
In-Reply-To: <200805161201.48835.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 12:01:48PM +1000, Rusty Russell wrote:
>
> Dave, please allow me to ask a heretical question.  Returning TX_BUSY has some 
> appeal for virtio_net: is it fundamentally a flawed idea, or simply a matter 
> of coding?

I don't think returning TX_BUSY is fundamentally flawed (unlike
LLTX which is).  However, until somebody (i.e., you :) writes
the code to handle it properly, i.e., not making the requeued
packet go through AF_PCAKET twice, it's something that shouldn't
be encouraged.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
