From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] bonding: fix active-backup transition
Date: Wed, 05 Apr 2017 07:16:35 -0700 (PDT)
Message-ID: <20170405.071635.1490651894506059902.davem@davemloft.net>
References: <20170404013839.1728-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753958AbdDEOQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:16:41 -0400
In-Reply-To: <20170404013839.1728-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Mon,  3 Apr 2017 18:38:39 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Earlier patch c4adfc822bf5 ("bonding: make speed, duplex setting
> consistent with link state") made an attempt to keep slave state
> consistent with speed and duplex settings. Unfortunately link-state
> transition is used to change the active link especially when used
> in conjunction with mii-mon. The above mentioned patch broke that
> logic. Also when speed and duplex settings for a link are updated
> during a link-event, the link-status should not be changed to
> invoke correct transition logic.
> 
> This patch fixes this issue by moving the link-state update outside
> of the bond_update_speed_duplex() fn and to the places where this fn
> is called and update link-state selectively.
> 
> Fixes: c4adfc822bf5 ("bonding: make speed, duplex setting consistent
> with link state")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
