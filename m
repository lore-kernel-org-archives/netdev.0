From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipmr: Add ipmr_rtm_getroute
Date: Thu, 29 Jun 2017 15:39:40 -0400 (EDT)
Message-ID: <20170629.153940.2163055966180522744.davem@davemloft.net>
References: <20170628175857.20447-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: sharpd@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdF2Tjr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:39:47 -0400
In-Reply-To: <20170628175857.20447-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Donald Sharp <sharpd@cumulusnetworks.com>
Date: Wed, 28 Jun 2017 13:58:57 -0400

> Add to RTNL_FAMILY_IPMR, RTM_GETROUTE the ability
> to retrieve one S,G mroute from a specified table.
> 
> *,G will return mroute information for just that
> particular mroute if it exists.  This is because
> it is entirely possible to have more S's then
> can fit in one skb to return to the requesting
> process.
> 
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>

Applied to net-next, thanks.
