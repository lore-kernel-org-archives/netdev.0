From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] dccp/tcp: do not inherit mc_list from parent
Date: Tue, 09 May 2017 15:18:21 -0400 (EDT)
Message-ID: <20170509.151821.971676153599667777.davem@davemloft.net>
References: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
        <1494336559.7796.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pray3r.z@gmail.com, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdEITSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 15:18:22 -0400
In-Reply-To: <1494336559.7796.78.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 May 2017 06:29:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller found a way to trigger double frees from ip_mc_drop_socket()
> 
> It turns out that leave a copy of parent mc_list at accept() time,
> which is very bad.
> 
> Very similar to commit 8b485ce69876 ("tcp: do not inherit
> fastopen_req from parent")
> 
> Initial report from Pray3r, completed by Andrey one.
> Thanks a lot to them !
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Pray3r <pray3r.z@gmail.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> ---
> v2: fix moved into inet_csk_clone_lock() to fix both DCCP and TCP

Applied and queued up for -stable, thanks Eric.
