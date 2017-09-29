From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: add per-port group_fwd_mask with
 less restrictions
Date: Fri, 29 Sep 2017 06:04:18 +0100 (WEST)
Message-ID: <20170929.060418.1634372835635805803.davem@davemloft.net>
References: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751830AbdI2LAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 07:00:32 -0400
In-Reply-To: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed, 27 Sep 2017 16:12:44 +0300

> We need to be able to transparently forward most link-local frames via
> tunnels (e.g. vxlan, qinq). Currently the bridge's group_fwd_mask has a
> mask which restricts the forwarding of STP and LACP, but we need to be able
> to forward these over tunnels and control that forwarding on a per-port
> basis thus add a new per-port group_fwd_mask option which only disallows
> mac pause frames to be forwarded (they're always dropped anyway).
> The patch does not change the current default situation - all of the others
> are still restricted unless configured for forwarding.
> We have successfully tested this patch with LACP and STP forwarding over
> VxLAN and qinq tunnels.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
