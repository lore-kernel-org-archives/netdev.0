From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix out-of-bounds access in ULP sysctl
Date: Fri, 23 Jun 2017 14:10:17 -0400 (EDT)
Message-ID: <20170623.141017.620234771116563109.davem@davemloft.net>
References: <20170623015755.23499-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borisp@mellanox.com, davejwatson@fb.com,
        oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34958 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754336AbdFWSKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:10:19 -0400
In-Reply-To: <20170623015755.23499-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 22 Jun 2017 18:57:55 -0700

> KASAN reports out-of-bound access in proc_dostring() coming from
> proc_tcp_available_ulp() because in case TCP ULP list is empty
> the buffer allocated for the response will not have anything
> printed into it.  Set the first byte to zero to avoid strlen()
> going out-of-bounds.
> 
> Fixes: 734942cc4ea6 ("tcp: ULP infrastructure")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied, thanks.
