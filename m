From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched actions: decrement module reference
 count after table flush.
Date: Sun, 26 Feb 2017 21:29:21 -0500 (EST)
Message-ID: <20170226.212921.96578974631677045.davem@davemloft.net>
References: <1487952032-508-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdB0Cxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:53:52 -0500
In-Reply-To: <1487952032-508-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Fri, 24 Feb 2017 11:00:32 -0500

> When tc actions are loaded as a module and no actions have been installed,
> flushing them would result in actions removed from the memory, but modules
> reference count not being decremented, so that the modules would not be
> unloaded.
...
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied and queued up for -stable, thanks.
