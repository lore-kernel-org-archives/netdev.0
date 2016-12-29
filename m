From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnl: stats - add missing netlink message size
 checks
Date: Thu, 29 Dec 2016 14:06:09 -0500 (EST)
Message-ID: <20161229.140609.389807839111668344.davem@davemloft.net>
References: <1482943935-18052-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752507AbcL2TGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 14:06:13 -0500
In-Reply-To: <1482943935-18052-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Wed, 28 Dec 2016 17:52:15 +0100

> We miss to check if the netlink message is actually big enough to contain
> a struct if_stats_msg.
> 
> Add a check to prevent userland from sending us short messages that would
> make us access memory beyond the end of the message.
> 
> Fixes: 10c9ead9f3c6 ("rtnetlink: add new RTM_GETSTATS message to dump...")
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Looks good, applied and queued up for -stable.
