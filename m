From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp: fixed -Wuninitialized compiler warning
Date: Thu, 25 May 2017 13:38:57 -0400 (EDT)
Message-ID: <20170525.133857.899186405679934528.davem@davemloft.net>
References: <20170524221935.11167-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: ihrachys@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969916AbdEYRi6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:38:58 -0400
In-Reply-To: <20170524221935.11167-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ihar Hrachyshka <ihrachys@redhat.com>
Date: Wed, 24 May 2017 15:19:35 -0700

> Commit 7d472a59c0e5ec117220a05de6b370447fb6cb66 ("arp: always override
> existing neigh entries with gratuitous ARP") introduced a compiler
> warning:
> 
> net/ipv4/arp.c:880:35: warning: 'addr_type' may be used uninitialized in
> this function [-Wmaybe-uninitialized]
> 
> While the code logic seems to be correct and doesn't allow the variable
> to be used uninitialized, and the warning is not consistently
> reproducible, it's still worth fixing it for other people not to waste
> time looking at the warning in case it pops up in the build environment.
> Yes, compiler is probably at fault, but we will need to accommodate.
> 
> Fixes: 7d472a59c0e5ec117220a05de6b370447fb6cb66
> Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>

Applied, but please in the future format your Fixes: tag properly
which should have been:

Fixes: 7d472a59c0e5 ("arp: always override existing neigh entries with gratuitous ARP")

Thanks.
