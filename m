From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next 0/7] net: ILA resolver and generic resolver
 backend
Date: Tue, 20 Sep 2016 17:43:53 +0800
Message-ID: <20160920094353.GA21050@gondor.apana.org.au>
References: <20160918.221024.2210003128839126114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com,
        roopa@cumulusnetworks.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54139 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752145AbcITJoD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:44:03 -0400
Content-Disposition: inline
In-Reply-To: <20160918.221024.2210003128839126114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> Can you please repost this series with Herbert Xu properly CC:'d
> since he maintains rhashtable and is making changes to it recently
> which might conflict with what you are proposing here?

There is no need to respost this series as is since I've just found
it :)

But I'd like to hear from Tom regarding

1) Why couldn't jhash be called directly instead of through rhashtable?
2) Making rhashtable parameters constanst since otherwise the inlining
will suck.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
