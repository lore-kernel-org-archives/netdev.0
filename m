From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 3/3] netlink: Use rhashtable walk interface in diag
 dump
Date: Fri, 19 Aug 2016 18:32:37 +0200
Message-ID: <20160819163237.GC29430@pox.localdomain>
References: <20160818084854.GA11502@gondor.apana.org.au>
 <E1baJ2Q-00031S-MH@gondolin.me.apana.org.au>
 <20160819080923.GA21419@gondor.apana.org.au>
 <20160819082137.GA21510@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36850 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754011AbcHSQck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:32:40 -0400
Received: by mail-wm0-f54.google.com with SMTP id q128so41097342wma.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 09:32:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160819082137.GA21510@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/16 at 04:21pm, Herbert Xu wrote:
> This patch converts the diag dumping code to use the rhashtable
> walk code instead of going through rhashtable by hand.  The lock
> nl_table_lock is now only taken while we process the multicast
> list as it's not needed for the rhashtable walk.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

LGTM. Curious, what did you use to test this? I've been struggling
to find a good test case.
