From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] qed*: Light L2 updates
Date: Fri, 09 Jun 2017 15:49:43 -0400 (EDT)
Message-ID: <20170609.154943.1439503170540178586.davem@davemloft.net>
References: <20170609141325.20547-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Michal.Kalderon@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751639AbdFITtp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:49:45 -0400
In-Reply-To: <20170609141325.20547-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Fri, 9 Jun 2017 17:13:17 +0300

> This series does a major overhaul of the LL2 logic in qed.
> The single biggest change done here is in #5 where we're changing
> the API qed provides for LL2 [both internally in case of storage and
> externally in case of RoCE] to become callback-based to allow cleaner
> scalability in preperation to the future iWARP submission which would
> aadd additional flavors of LL2. It's also the only patch in series
> to modify !qed logic [qedr].
> 
> Patches prior to that mostly deal with refactoring LL2 code,
> encapsulating varaious parameters into structure and re-ordering
> of LL2 code. The latter patches add some small missing bits of LL2
> ffunctionality.

Series applied, thank you.
