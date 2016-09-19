From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 11:31:11 +0200
Message-ID: <1474277471.4469.22.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
         <20160919084056.GA11875@gondor.apana.org.au>
         <1474276530.4469.16.camel@sipsolutions.net>
         <20160919091721.GA12235@gondor.apana.org.au>
         <1474277244.4469.21.camel@sipsolutions.net>
         (sfid-20160919_112742_960386_2D82BED9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com, Ben Greear <greearb@candelatech.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50113 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751414AbcISJbR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 05:31:17 -0400
In-Reply-To: <1474277244.4469.21.camel@sipsolutions.net> (sfid-20160919_112742_960386_2D82BED9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-19 at 11:27 +0200, Johannes Berg wrote:
> > 
> I have a feeling there's a bug with ht->nelems, since the crash is
> always in the grow worker, but I haven't quite put my finger on it
> yet.
> 
Btw, I should not actually get into the duplicate case here.

johannes
