From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vti6: fix device register to report IFLA_INFO_KIND
Date: Fri, 06 Jan 2017 16:09:21 -0500 (EST)
Message-ID: <20170106.160921.1048190214100280359.davem@davemloft.net>
References: <1483698479-20445-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dforster@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdAFVJW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:09:22 -0500
In-Reply-To: <1483698479-20445-1-git-send-email-dforster@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Forster <dforster@brocade.com>
Date: Fri, 6 Jan 2017 10:27:59 +0000

> vti6 interface is registered before the rtnl_link_ops block
> is attached. As a result the resulting RTM_NEWLINK is missing
> IFLA_INFO_KIND. Re-order attachment of rtnl_link_ops block to fix.
> 
> Signed-off-by: Dave Forster <dforster@brocade.com>

Applied, thanks.
