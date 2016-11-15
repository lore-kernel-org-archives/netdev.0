From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] udplite: fix NULL pointer dereference
Date: Tue, 15 Nov 2016 11:59:53 -0500 (EST)
Message-ID: <20161115.115953.28961096557280844.davem@redhat.com>
References: <ac389a539b9299b44f63a2d1f744a637a8126943.1479223645.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, avagin@gmail.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752246AbcKOQ76 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 11:59:58 -0500
In-Reply-To: <ac389a539b9299b44f63a2d1f744a637a8126943.1479223645.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 15 Nov 2016 16:37:53 +0100

> The commit 850cbaddb52d ("udp: use it's own memory accounting schema")
> assumes that the socket proto has memory accounting enabled,
> but this is not the case for UDPLITE.
> Fix it enabling memory accounting for UDPLITE and performing
> fwd allocated memory reclaiming on socket shutdown.
> UDP and UDPLITE share now the same memory accounting limits.
> Also drop the backlog receive operation, since is no more needed.
> 
> Fixes: 850cbaddb52d ("udp: use it's own memory accounting schema")
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thank you.
