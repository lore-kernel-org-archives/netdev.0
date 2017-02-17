From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 0/7] net/sched: Reflect HW offload status
 in classifiers
Date: Fri, 17 Feb 2017 12:08:33 -0500 (EST)
Message-ID: <20170217.120833.2228965207602375369.davem@davemloft.net>
References: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, roid@mellanox.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934122AbdBQRIk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 12:08:40 -0500
In-Reply-To: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 16 Feb 2017 10:31:09 +0200

> Currently there is no way of querying whether a filter is
> offloaded to HW or not when using "both" policy (where none
> of skip_sw or skip_hw flags are set by user-space).
> 
> Added two new flags, "in hw" and "not in hw" such that user space 
> can determine if a filter is actually offloaded to hw. The "in hw" 
> UAPI semantics was chosen so it's similar to the "skip hw" flag logic.
> 
> If none of these two flags are set, this signals running
> over older kernel.
 ...

Series applied, thanks Or.
