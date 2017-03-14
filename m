From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Resend IGMP memberships upon peer notification.
Date: Tue, 14 Mar 2017 11:34:23 -0700 (PDT)
Message-ID: <20170314.113423.139578310634947031.davem@davemloft.net>
References: <1489496288-24139-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
        vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdCNSeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:34:25 -0400
In-Reply-To: <1489496288-24139-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 14 Mar 2017 08:58:08 -0400

> When we notify peers of potential changes,  it's also good to update
> IGMP memberships.  For example, during VM migration, updating IGMP
> memberships will redirect existing multicast streams to the VM at the
> new location.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
