From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: qcom/emac: do not reset the EMAC during
 initialization
Date: Fri, 23 Jun 2017 14:00:31 -0400 (EDT)
Message-ID: <20170623.140031.865751442887165393.davem@davemloft.net>
References: <1498154732-19854-1-git-send-email-timur@codeaurora.org>
        <1498154732-19854-3-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34748 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754109AbdFWSAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:00:32 -0400
In-Reply-To: <1498154732-19854-3-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 22 Jun 2017 13:05:31 -0500

> It doesn't make sense to reset the EMAC in the middle of initializing
> it during the probe.
> 
> Tested-by: Richard Ruigrok <rruigrok@codeaurora.org>
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Why not?

What if the boot loader or something else left the chip in
a weird state?

I'm not applying this.

If it's correct, the explanation in this commit message need
to be imporved.  The change must be better justified.
