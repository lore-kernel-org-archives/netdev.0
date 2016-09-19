From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [v3 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 13:03:43 +0200
Message-ID: <1474283023.6544.0.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
         <20160919084056.GA11875@gondor.apana.org.au>
         <20160919105854.GA12892@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com, Ben Greear <greearb@candelatech.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50524 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751694AbcISLDv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 07:03:51 -0400
In-Reply-To: <20160919105854.GA12892@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-19 at 18:58 +0800, Herbert Xu wrote:
> v3 fixes a bug in the remove path that causes the element count
> to decrease when it shouldn't, leading to a gigantic hash table
> when it underflows.
> 
Ok, with the BUG_ON() thrown in, this works in the test that was
failing before. I'll run the entire suite again over lunch.

johannes
