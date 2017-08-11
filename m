From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net repost] nfp: do not update MTU from BH in flower app
Date: Fri, 11 Aug 2017 14:51:07 -0700 (PDT)
Message-ID: <20170811.145107.1539668262080149471.davem@davemloft.net>
References: <1502439500-16047-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753533AbdHKVvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:51:08 -0400
In-Reply-To: <1502439500-16047-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri, 11 Aug 2017 10:18:20 +0200

> The Flower app may receive a request to update the MTU of a representor
> netdev upon receipt of a control message from the firmware. This requires
> the RTNL lock which needs to be taken outside of the packet processing
> path.
> 
> As a handling of this correctly seems a little to invasive for a fix simply
> skip setting the MTU for now.
> 
> Relevant backtrace:
 ...
> Fixes: 948faa46c05b ("nfp: add support for control messages for flower app")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
