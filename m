From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: don't send unknown nsid
Date: Thu, 01 Jun 2017 11:50:08 -0400 (EDT)
Message-ID: <20170601.115008.959194105881624590.davem@davemloft.net>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
        <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@sysclose.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752395AbdFAPuU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:50:20 -0400
In-Reply-To: <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  1 Jun 2017 10:00:07 +0200

> The NETLINK_F_LISTEN_ALL_NSID otion enables to listen all netns that have a
> nsid assigned into the netns where the netlink socket is opened.
> The nsid is sent as metadata to userland, but the existence of this nsid is
> checked only for netns that are different from the socket netns. Thus, if
> no nsid is assigned to the socket netns, NETNSA_NSID_NOT_ASSIGNED is
> reported to the userland. This value is confusing and useless.
> After this patch, only valid nsid are sent to userland.
> 
> Reported-by: Flavio Leitner <fbl@sysclose.org>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thank you.
