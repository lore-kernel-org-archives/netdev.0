From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 16:40:57 +0800
Message-ID: <20160919084056.GA11875@gondor.apana.org.au>
References: <20160804071846.GA773@gondor.apana.org.au>
 <20160804074546.GA996@gondor.apana.org.au>
 <1470377813.2977.14.camel@sipsolutions.net>
 <20160805104858.GA9297@gondor.apana.org.au>
 <1470394233.2977.37.camel@sipsolutions.net>
 <20160918135030.GA7062@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com, Ben Greear <greearb@candelatech.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57679 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754044AbcISIlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 04:41:06 -0400
Content-Disposition: inline
In-Reply-To: <20160918135030.GA7062@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 contains a reworked insertion slowpath to ensure that the
spinlock for the table we're inserting into is taken.

This series contains one two patches.  The first adds the rhlist
interface and the second converts mac80211 to use it.  If this works
out I'll then proceed to convert the other insecure_elasticity
users over to this.

I've tested the rhlist code with test_rhashtable but I haven't
tested the mac80211 conversion.  So please give it a go and see
if it still works.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
