From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 10:25:18 +0200
Message-ID: <1474273518.4469.8.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
         <1474273219.4469.7.camel@sipsolutions.net>
         (sfid-20160919_102334_213492_CF017D1F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49744 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759746AbcISIZY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 04:25:24 -0400
In-Reply-To: <1474273219.4469.7.camel@sipsolutions.net> (sfid-20160919_102334_213492_CF017D1F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Yes, it's passing all the wpa_supplicant tests, so
> 
> Acked-by: Johannes Berg <johannes@sipsolutions.net>
> 

I take that back. I think it's leaking memory - my tests never used to
run out of memory, but now they eventually do.

I'll try to figure out more.

johannes
