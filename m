From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix src address selection if using secondary
 addresses for ipv6
Date: Fri, 12 May 2017 10:51:52 -0400 (EDT)
Message-ID: <20170512.105152.1598182497069259027.davem@davemloft.net>
References: <7bbcf970cdc9eca6de6132a942d8c46eb7e138c0.1494571192.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756399AbdELOvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 10:51:54 -0400
In-Reply-To: <7bbcf970cdc9eca6de6132a942d8c46eb7e138c0.1494571192.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 12 May 2017 14:39:52 +0800

> Commit 0ca50d12fe46 ("sctp: fix src address selection if using secondary
> addresses") has fixed a src address selection issue when using secondary
> addresses for ipv4.
> 
> Now sctp ipv6 also has the similar issue. When using a secondary address,
> sctp_v6_get_dst tries to choose the saddr which has the most same bits
> with the daddr by sctp_v6_addr_match_len. It may make some cases not work
> as expected.
 ...
> This patch is to fix it with the same way as Marcelo's fix for sctp ipv4.
> As no ip_dev_find for ipv6, this patch is to use ipv6_chk_addr to check
> if the saddr is in a dev instead.
> 
> Note that for backwards compatibility, it will still do the addr_match_len
> check here when no optimal is found.
> 
> Reported-by: Patrick Talbert <ptalbert@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thank you.
