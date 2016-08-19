From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] netlink: Use rhashtable walk interface in diag dump
Date: Fri, 19 Aug 2016 16:09:23 +0800
Message-ID: <20160819080923.GA21419@gondor.apana.org.au>
References: <20160818084854.GA11502@gondor.apana.org.au>
 <E1baJ2Q-00031S-MH@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:55583 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753614AbcHSIKB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 04:10:01 -0400
Content-Disposition: inline
In-Reply-To: <E1baJ2Q-00031S-MH@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2016 at 04:50:58PM +0800, Herbert Xu wrote:
> This patch converts the diag dumping code to use the rhashtable
> walk code instead of going through rhashtable by hand.  The lock
> nl_table_lock is now only taken while we process the multicast
> list as it's not needed for the rhashtable walk.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Please drop this patch.  While the current dump is already buggy
my new version seems worse and returns a lot less entries.  I'll
post a new version of this patch when I figure out why.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
