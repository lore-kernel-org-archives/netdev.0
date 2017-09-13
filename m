From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bonding: fix tlb_dynamic_lb default value
Date: Tue, 12 Sep 2017 20:59:00 -0700 (PDT)
Message-ID: <20170912.205900.438222724554183210.davem@davemloft.net>
References: <1505218205-2637-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, maheshb@google.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751458AbdIMD7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 23:59:01 -0400
In-Reply-To: <1505218205-2637-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 12 Sep 2017 15:10:05 +0300

> Commit 8b426dc54cf4 ("bonding: remove hardcoded value") changed the
> default value for tlb_dynamic_lb which lead to either broken ALB mode
> (since tlb_dynamic_lb can be changed only in TLB) or setting TLB mode
> with tlb_dynamic_lb equal to 0.
> The first issue was recently fixed by setting tlb_dynamic_lb to 1 always
> when switching to ALB mode, but the default value is still wrong and
> we'll enter TLB mode with tlb_dynamic_lb equal to 0 if the mode is
> changed via netlink or sysfs. In order to restore the previous behaviour
> and default value simply remove the mode check around the default param
> initialization for tlb_dynamic_lb which will always set it to 1 as
> before.
> 
> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
