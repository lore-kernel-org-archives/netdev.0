From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] af_key: Add lock to key dump
Date: Tue, 4 Apr 2017 08:39:31 +0200
Message-ID: <20170404063931.GV5092@secunet.com>
References: <1490944220-578-1-git-send-email-syjcnss@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <timo.teras@iki.fi>,
        <herbert@gondor.apana.org.au>
To: Yuejie Shi <syjcnss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46434 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752497AbdDDGkG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 02:40:06 -0400
Content-Disposition: inline
In-Reply-To: <1490944220-578-1-git-send-email-syjcnss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 31, 2017 at 03:10:20PM +0800, Yuejie Shi wrote:
> A dump may come in the middle of another dump, modifying its dump
> structure members. This race condition will result in NULL pointer
> dereference in kernel. So add a lock to prevent that race.
> 
> Fixes: 83321d6b9872 ("[AF_KEY]: Dump SA/SP entries non-atomically")
> Signed-off-by: Yuejie Shi <syjcnss@gmail.com>

Applied, thanks a lot!
