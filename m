From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mld: do not remove mld souce list info when set
 link down
Date: Mon, 16 Jan 2017 12:45:20 -0500 (EST)
Message-ID: <20170116.124520.1104251072700866507.davem@davemloft.net>
References: <1484227177-7857-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdAPRpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 12:45:25 -0500
In-Reply-To: <1484227177-7857-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Thu, 12 Jan 2017 21:19:37 +0800

> This is an IPv6 version of commit 24803f38a5c0 ("igmp: do not remove igmp
> souce list..."). In mld_del_delrec(), we will restore back all source filter
> info instead of flush them.
> 
> Move mld_clear_delrec() from ipv6_mc_down() to ipv6_mc_destroy_dev() since
> we should not remove source list info when set link down. Remove
> igmp6_group_dropped() in ipv6_mc_destroy_dev() since we have called it in
> ipv6_mc_down().
> 
> Also clear all source info after igmp6_group_dropped() instead of in it
> because ipv6_mc_down() will call igmp6_group_dropped().
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied.
