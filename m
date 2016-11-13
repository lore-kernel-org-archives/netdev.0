From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] igmp: do not remove igmp souce list info when
 set link down
Date: Sat, 12 Nov 2016 23:29:35 -0500 (EST)
Message-ID: <20161112.232935.1582203391859033298.davem@davemloft.net>
References: <1478661400-10152-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        daniel@iogearbox.net
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753498AbcKMEgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 23:36:51 -0500
In-Reply-To: <1478661400-10152-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Wed,  9 Nov 2016 11:16:40 +0800

> In commit 24cf3af(igmp: call ip_mc_clear_src...), we forgot to remove
> igmpv3_clear_delrec() in ip_mc_down(), which also called ip_mc_clear_src().
> This make us clear all IGMPv3 source filter info after NETDEV_DOWN.
> Move igmpv3_clear_delrec() to ip_mc_destroy_dev() and then no need
> ip_mc_clear_src() in ip_mc_destroy_dev().
> 
> On the other hand, we should restore back instead of free all source filter
> info in igmpv3_del_delrec(). Or we will not able to restore IGMPv3 source
> filter info after NETDEV_UP and NETDEV_POST_TYPE_CHANGE.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Commits must be referenced with 12 characters of significance in the
SHA1-ID and appear in an appropriately formed "Fixes: " tag right
before the signoffs.

As-per Documentation/SubmittingPatches.

It also doesn't look so good how you lack a space between the SHA1-ID
and the commit message header text reference.
