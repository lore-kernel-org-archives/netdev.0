From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] nfp: refactor app init, and minor flower
 fixes
Date: Sun, 03 Sep 2017 21:22:21 -0700 (PDT)
Message-ID: <20170903.212221.1440891147611396315.davem@davemloft.net>
References: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755010AbdIDEWW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 00:22:22 -0400
In-Reply-To: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sat,  2 Sep 2017 18:25:59 -0700

> This series is a part 2 to what went into net as a simpler fix.
> In net we simply moved when existing callbacks are invoked to
> ensure flower app does not still use representors when lower 
> netdev has already been destroyed.  In this series we add a
> callback to notify apps when vNIC netdevs are fully initialized
> and they are about to be destroyed.  This allows flower to spawn
> representors at the right time, while keeping the start/stop
> callbacks for what they are intended to be used - FW initialization
> over control channel.
> 
> Patch 4 improves drop monitor interaction and patch 5 changes 
> the default Kconfig selection of flower offload.  Patch 6 fixes
> locking around representor updates which got lost in net-next.

Series applied, thanks.
