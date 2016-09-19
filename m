From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 10:20:19 +0200
Message-ID: <1474273219.4469.7.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49726 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760151AbcISIU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 04:20:29 -0400
In-Reply-To: <20160918135030.GA7062@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> OK, it's finally ready now.
> 
> This series contains one two patches.  The first adds the rhlist
> interface and the second converts mac80211 to use it.  If this works
> out I'll then proceed to convert the other insecure_elasticity
> users over to this.

Thanks a lot Herbert!

> I've tested the rhlist code with test_rhashtable but I haven't
> tested the mac80211 conversion.  So please give it a go and see
> if it still works.

Yes, it's passing all the wpa_supplicant tests, so

Acked-by: Johannes Berg <johannes@sipsolutions.net>

I assume you want at least the first patch to be merged through net-
next so you can build on it.

Dave, I don't have anything pending right now since you just pulled, so
I can also wait for you to apply the rhltable and then merge the
mac80211 patch. If you apply the mac80211 patch directly I'll just wait
for both of them to show up and then I'll fast forward to your tree.

Thanks,
johannes
