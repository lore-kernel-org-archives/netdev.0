From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: FLR of active VFs might lead to FW assert
Date: Mon, 22 Aug 2016 18:18:48 -0700 (PDT)
Message-ID: <20160822.181848.1467939282286710395.davem@davemloft.net>
References: <1471856609-8519-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47265 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcHWBSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 21:18:49 -0400
In-Reply-To: <1471856609-8519-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 22 Aug 2016 12:03:29 +0300

> Driver never bothered marking the VF's vport with the VF's sw_fid.
> As a result, FLR flows are not going to clean those vports.
> 
> If the vport was active when FLRed, re-activating it would lead
> to a FW assertion.
> 
> Fixes: dacd88d6f6851 ("qed: IOV l2 functionality")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
