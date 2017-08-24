From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sock: allow the user to set negative peek
 offset
Date: Wed, 23 Aug 2017 22:19:21 -0700 (PDT)
Message-ID: <20170823.221921.542562782486867988.davem@davemloft.net>
References: <64e676e59d203f13cd326c3b0cf6b05287b69e1b.1503481941.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthew@mjdsystems.ca,
        willemdebruijn.kernel@gmail.com, samanthakumar@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdHXFTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:19:22 -0400
In-Reply-To: <64e676e59d203f13cd326c3b0cf6b05287b69e1b.1503481941.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 23 Aug 2017 11:57:51 +0200

> This is necessary to allow the user to disable peeking with
> offset once it's enabled.
> Unix sockets already allow the above, with this patch we
> permit it for udp[6] sockets, too.
> 
> Fixes: 627d2d6b5500 ("udp: enable MSG_PEEK at non-zero offset")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied to net-next.
