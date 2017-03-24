From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: add module param to set max-rss-queues.
Date: Fri, 24 Mar 2017 14:12:37 -0700 (PDT)
Message-ID: <20170324.141237.1992801159655201421.davem@davemloft.net>
References: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966588AbdCXVMi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:12:38 -0400
In-Reply-To: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Fri, 24 Mar 2017 13:58:47 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> In systems where you may have a very large number of network
> adapters, certain drivers may consume an unfair amount of
> IRQ resources.  So, allow a module param that will limit the
> number of IRQs at driver load time.  This way, other drivers
> (40G Ethernet, for instance), which probably will need the
> multiple IRQs more, will not be starved of IRQ resources.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Sorry, no module params.

Use generic run-time facilities such as ethtool to configure
such things.
