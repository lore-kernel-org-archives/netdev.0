From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: TX time stamp packets before HW doorbell is
 rung
Date: Wed, 23 Aug 2017 22:41:28 -0700 (PDT)
Message-ID: <20170823.224128.1575286278485663410.davem@davemloft.net>
References: <20170823214150.29989-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdHXFl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:41:28 -0400
In-Reply-To: <20170823214150.29989-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 23 Aug 2017 14:41:50 -0700

> TX completion may happen any time after HW queue was kicked.
> We can't access the skb afterwards.  Move the time stamping
> before ringing the doorbell.
> 
> Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks.

If I had a nickel for every time this mistake was made...
