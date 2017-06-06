From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: fix a null pointer dereference in
 br_afspec
Date: Tue, 06 Jun 2017 16:06:01 -0400 (EDT)
Message-ID: <20170606.160601.292169589611249662.davem@davemloft.net>
References: <840022de-3d31-4f62-aaaf-ba83d5c78ad7@cumulusnetworks.com>
        <1496701584-26855-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, garsilva@embeddedor.com,
        bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38180 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdFFUGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:06:02 -0400
In-Reply-To: <1496701584-26855-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue,  6 Jun 2017 01:26:24 +0300

> We might call br_afspec() with p == NULL which is a valid use case if
> the action is on the bridge device itself, but the bridge tunnel code
> dereferences the p pointer without checking, so check if p is null
> first.
> 
> Reported-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks Nikolay.
