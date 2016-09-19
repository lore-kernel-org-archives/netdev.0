From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 18:48:01 +0800
Message-ID: <20160919104801.GA12774@gondor.apana.org.au>
References: <20160919084056.GA11875@gondor.apana.org.au>
 <1474276530.4469.16.camel@sipsolutions.net>
 <20160919091721.GA12235@gondor.apana.org.au>
 <1474277244.4469.21.camel@sipsolutions.net>
 <20160919093434.GA12378@gondor.apana.org.au>
 <1474278634.4469.25.camel@sipsolutions.net>
 <1474278896.4469.26.camel@sipsolutions.net>
 <1474279330.4469.28.camel@sipsolutions.net>
 <1474279492.4469.29.camel@sipsolutions.net>
 <1474279827.4469.30.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com, Ben Greear <greearb@candelatech.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54020 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754766AbcISKsN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 06:48:13 -0400
Content-Disposition: inline
In-Reply-To: <1474279827.4469.30.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 12:10:27PM +0200, Johannes Berg wrote:
> Btw, for debug I put
> 
> BUG_ON(atomic_read(&ht->nelems) < 0);
> 
> after the atomic_dec() in __rhashtable_remove_fast_one(). That makes
> the kernel crash instantly on the buggy code, and I just have to run a
> single test ("wpas_ctrl_interface_add_many") to get there.

Aha I see the problem now.  The nelems logic on remove is broken.
I'll send out a v3.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
