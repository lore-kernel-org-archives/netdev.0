From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: fix needed_headroom and max_mtu for
 collect_metadata
Date: Sun, 04 Jun 2017 20:04:27 -0400 (EDT)
Message-ID: <20170604.200427.359347649096470847.davem@davemloft.net>
References: <20170602185410.10971-1-e@erig.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: e@erig.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdFEAE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 20:04:29 -0400
In-Reply-To: <20170602185410.10971-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Garver <e@erig.me>
Date: Fri,  2 Jun 2017 14:54:10 -0400

> Since commit 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> when using COLLECT_METADATA geneve devices are created with too small of
> a needed_headroom and too large of a max_mtu. This is because
> ip_tunnel_info_af() is not valid with the device level info when using
> COLLECT_METADATA and we mistakenly fall into the IPv4 case.
> 
> For COLLECT_METADATA, always use the worst case of ipv6 since both
> sockets are created.
> 
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Eric Garver <e@erig.me>

Applied and queued up for -stable, thanks.
