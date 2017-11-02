From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: add notifications for the bridge
 dev on vlan change
Date: Thu, 02 Nov 2017 15:54:17 +0900 (KST)
Message-ID: <20171102.155417.1598178495654566553.davem@davemloft.net>
References: <1509531493-17909-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43818 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755230AbdKBGyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 02:54:21 -0400
In-Reply-To: <1509531493-17909-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed,  1 Nov 2017 12:18:13 +0200

> Currently the bridge device doesn't generate any notifications upon vlan
> modifications on itself because it doesn't use the generic bridge
> notifications.
> With the recent changes we know if anything was modified in the vlan config
> thus we can generate a notification when necessary for the bridge device
> so add support to br_ifinfo_notify() similar to how other combined
> functions are done - if port is present it takes precedence, otherwise
> notify about the bridge. I've explicitly marked the locations where the
> notification should be always for the port by setting bridge to NULL.
> I've also taken the liberty to rearrange each modified function's local
> variables in reverse xmas tree as well.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
