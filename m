From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 3/3] netlink: Use rhashtable walk interface in diag
 dump
Date: Sat, 20 Aug 2016 00:39:02 +0800
Message-ID: <20160819163902.GB24067@gondor.apana.org.au>
References: <20160818084854.GA11502@gondor.apana.org.au>
 <E1baJ2Q-00031S-MH@gondolin.me.apana.org.au>
 <20160819080923.GA21419@gondor.apana.org.au>
 <20160819082137.GA21510@gondor.apana.org.au>
 <20160819163237.GC29430@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41128 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755006AbcHSQjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:39:10 -0400
Content-Disposition: inline
In-Reply-To: <20160819163237.GC29430@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 06:32:37PM +0200, Thomas Graf wrote:
> On 08/19/16 at 04:21pm, Herbert Xu wrote:
> > This patch converts the diag dumping code to use the rhashtable
> > walk code instead of going through rhashtable by hand.  The lock
> > nl_table_lock is now only taken while we process the multicast
> > list as it's not needed for the rhashtable walk.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> LGTM. Curious, what did you use to test this? I've been struggling
> to find a good test case.

ss -A netlink

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
