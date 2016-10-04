From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] qed*: Add qedr infrastructure support
Date: Mon, 03 Oct 2016 23:24:46 -0400 (EDT)
Message-ID: <20161003.232446.1827173235395776859.davem@davemloft.net>
References: <1475348401-31392-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Ram.Amrani@caviumnetworks.com, Michal.Kalderon@caviumnetworks.com,
        Ariel.Elior@caviumnetworks.com, dledford@redhat.com
To: Yuval.Mintz@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbcJDDYw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 23:24:52 -0400
In-Reply-To: <1475348401-31392-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
Date: Sat, 1 Oct 2016 21:59:54 +0300

> In the last couple of weeks we've been sending RFCs for the qedr
> driver - the RoCE driver for QLogic FastLinQ 4xxxx line of adapters.
> Latest RFC can be found at [1].
> 
> At Doug's advice [2], we've decided to split the series into two:
>  - first part contains the qed backbone that's necessary for all the
> configurations relating to the qedr driver, as well as the qede
> infrastructure that is used for communication between the qedr and qede.
>  - Second part consists of the actual qedr driver and introduces almost
> no changes to qed/qede.
> 
> This is the first of said two parts. The second half would be sent
> later this week.
> 
> The only 'oddity' in the devision are the Kconfig options - 
> As this series introduces both LL2 and QEDR-based logic in qed/qede,
> I wanted to add the CONFIG_INFINIBAND_QEDR option here [with default n].
> Otherwise, a lot of the code introduced would be dead-code [won't even
> be compiled] until qedr is accepted.
> As a result I've placed the config option in an odd place - under
> qlogic's Kconfig. The second series would then remove that option
> and add it in its correct place under the infiniband Kconfig.
> [I'm fine with pushing it there to begin with, but I didn't want to
> 'contaminate' non-qlogic configuration files with half-baked options].
> 
> Dave - I don't think you were E-mailed with Doug's suggestion.
> I think the notion was to have the two halves accepted side-by-side,
> but actually the first has no dependency issues, so it's also
> possible to simply take this first to net-next, and push the qedr
> into rdma once it's merged. But it's basically up to you and Doug;
> We'd align with whatever suits you best.

I'll take this, series applied, thanks.
