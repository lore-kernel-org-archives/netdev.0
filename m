From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] nfp: fix SR-IOV deadlock and representor bugs
Date: Wed, 23 Aug 2017 20:40:18 -0700 (PDT)
Message-ID: <20170823.204018.2122046172444891539.davem@davemloft.net>
References: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58272 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdHXDkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:40:19 -0400
In-Reply-To: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 22 Aug 2017 23:22:41 -0700

> This series tackles the bug I've already tried to fix in commit 
> 6d48ceb27af1 ("nfp: allocate a private workqueue for driver work").
> I created a separate workqueue to avoid possible deadlock, and
> the lockdep error disappeared, coincidentally.  The way workqueues
> are operating, separate workqueue doesn't necessarily mean separate
> thread of execution.  Luckily we can safely forego the lock.
> 
> Second fix changes the order in which vNIC netdevs and representors
> are created/destroyed.  The fix is kept small and should be sufficient
> for net because of how flower uses representors, a more thorough fix 
> will be targeted at net-next.
> 
> Third fix avoids leaking mapped frame buffers if FW sent a frame with
> unknown portid.

Series applied, thanks.
