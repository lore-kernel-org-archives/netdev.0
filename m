From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net] igmp: do not remove igmp souce list info when
 set link down
Date: Tue, 15 Nov 2016 19:51:42 -0500 (EST)
Message-ID: <20161115.195142.1921064214545163262.davem@davemloft.net>
References: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        daniel@iogearbox.net
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbcKPAvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:51:47 -0500
In-Reply-To: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Mon, 14 Nov 2016 16:16:28 +0800

> In commit 24cf3af3fed5 ("igmp: call ip_mc_clear_src..."), we forgot to remove
> igmpv3_clear_delrec() in ip_mc_down(), which also called ip_mc_clear_src().
> This make us clear all IGMPv3 source filter info after NETDEV_DOWN.
> Move igmpv3_clear_delrec() to ip_mc_destroy_dev() and then no need
> ip_mc_clear_src() in ip_mc_destroy_dev().
> 
> On the other hand, we should restore back instead of free all source filter
> info in igmpv3_del_delrec(). Or we will not able to restore IGMPv3 source
> filter info after NETDEV_UP and NETDEV_POST_TYPE_CHANGE.
> 
> Fixes: 24cf3af3fed5 ("igmp: call ip_mc_clear_src() only when ...")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied.
