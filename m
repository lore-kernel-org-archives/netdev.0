From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnelink: Move link dump consistency check
 out of the loop
Date: Sun, 13 Aug 2017 19:44:12 -0700 (PDT)
Message-ID: <20170813.194412.429768431959485148.davem@davemloft.net>
References: <20170809153912.19733-1-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752225AbdHNCoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 22:44:13 -0400
In-Reply-To: <20170809153912.19733-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Wed,  9 Aug 2017 17:39:12 +0200

> Calls to rtnl_dump_ifinfo() are protected by RTNL lock. So are the
> {list,unlist}_netdevice() calls where we bump the net->dev_base_seq
> number.
> 
> For this reason net->dev_base_seq can't change under out feet while
> we're looping over links in rtnl_dump_ifinfo(). So move the check for
> net->dev_base_seq change (since the last time we were called) out of the
> loop.
> 
> This way we avoid giving a wrong impression that there are concurrent
> updates to the link list going on while we're iterating over them.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Applied, thanks.
