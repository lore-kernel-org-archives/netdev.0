From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Replace 2 jiffies with sysctl
 netdev_budget_usecs to enable softirq tuning
Date: Fri, 21 Apr 2017 13:22:45 -0400 (EDT)
Message-ID: <20170421.132245.1207278487695293623.davem@davemloft.net>
References: <1492619830-7561-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424495AbdDUTHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:07:35 -0400
In-Reply-To: <1492619830-7561-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Wed, 19 Apr 2017 12:37:10 -0400

> Constants used for tuning are generally a bad idea, especially as hardware
> changes over time. Replace the constant 2 jiffies with sysctl variable
> netdev_budget_usecs to enable sysadmins to tune the softirq processing.
> Also document the variable.
> 
> For example, a very fast machine might tune this to 1000 microseconds,
> while my regression testing 486DX-25 needs it to be 4000 microseconds on
> a nearly idle network to prevent time_squeeze from being incremented.
> 
> Version 2: changed jiffies to microseconds for predictable units.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

Applied, thanks.
