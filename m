From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: WARNING: at net/core/dev.c:1505 skb_gso_segment+0x6e/0x156()
Date: Mon, 2 Mar 2009 12:15:42 +0800
Message-ID: <20090302041542.GA15961@gondor.apana.org.au>
References: <Pine.LNX.4.64.0902262309380.4261@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34366 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755504AbZCBEPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:15:48 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902262309380.4261@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Stromsoe <cbs@cts.ucla.edu> wrote:
> I'm seeing these show up pretty regularly on several Dell 1750s running 
> 2.6.27.19, with both tg3 ports bonded together in an active-backup 
> configuration.

Please try to reproduce this under 2.6.28-rcX where it'll print more
details about what went wrong.  I'd suspect that something went
amiss with the features computation on the bonding device.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
