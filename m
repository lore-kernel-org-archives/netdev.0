From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 11:12:32 +0200
Message-ID: <1343293952.2626.11244.camel@edumazet-glaptop>
References: <1343290414.2626.11181.camel@edumazet-glaptop>
	 <20120726.011853.973075299731735416.davem@davemloft.net>
	 <1343291278.2626.11188.camel@edumazet-glaptop>
	 <20120726.014736.1066206957795563053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44327 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab2GZJMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 05:12:37 -0400
Received: by bkwj10 with SMTP id j10so1122583bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 02:12:36 -0700 (PDT)
In-Reply-To: <20120726.014736.1066206957795563053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 01:47 -0700, David Miller wrote:

> Indeed, thanks for catching this bug.
> 
> Here's a new version of the patch, as I found another error.  In
> fib_semantics.c, we have to change dst_release() to dst_free() for the
> liberation the nexthop cached routes.

Excellent, I did tests here and this seems ok to me

Tested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
