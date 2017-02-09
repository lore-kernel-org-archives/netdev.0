From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] igmp, mld: Fix memory leak in
 igmpv3/mld_del_delrec()
Date: Thu, 09 Feb 2017 16:47:04 -0500 (EST)
Message-ID: <20170209.164704.601696075811710644.davem@davemloft.net>
References: <1486559805-28482-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753096AbdBIV5Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:57:16 -0500
In-Reply-To: <1486559805-28482-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Wed,  8 Feb 2017 21:16:45 +0800

> In function igmpv3/mld_add_delrec() we allocate pmc and put it in
> idev->mc_tomb, so we should free it when we don't need it in del_delrec().
> But I removed kfree(pmc) incorrectly in latest two patches. Now fix it.
> 
> Fixes: 24803f38a5c0 ("igmp: do not remove igmp souce list info when ...")
> Fixes: 1666d49e1d41 ("mld: do not remove mld souce list info when ...")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied and queued up for -stable, thanks.
