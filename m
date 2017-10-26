From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/unix: don't show information about sockets from
 other namespaces
Date: Thu, 26 Oct 2017 10:06:48 +0900 (KST)
Message-ID: <20171026.100648.1957689192376657185.davem@davemloft.net>
References: <1508938636.30291.115.camel@edumazet-glaptop3.roam.corp.google.com>
        <20171025171642.2926-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbdJZBGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:06:51 -0400
In-Reply-To: <20171025171642.2926-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Wed, 25 Oct 2017 10:16:42 -0700

> socket_diag shows information only about sockets from a namespace where
> a diag socket lives.
> 
> But if we request information about one unix socket, the kernel don't
> check that its netns is matched with a diag socket namespace, so any
> user can get information about any unix socket in a system. This looks
> like a bug.
> 
> v2: add a Fixes tag
> 
> Fixes: 51d7cccf0723 ("net: make sock diag per-namespace")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied and queued up for -stable, thanks!
