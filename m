From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bonding: commit link status change after propose
Date: Wed, 26 Jul 2017 13:43:04 -0700 (PDT)
Message-ID: <20170726.134304.333435908935281738.davem@davemloft.net>
References: <20170725164425.9112-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.gilbert@coreos.com,
        maheshb@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdGZUnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 16:43:05 -0400
In-Reply-To: <20170725164425.9112-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 25 Jul 2017 09:44:25 -0700

> Commit de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
> moves link status commitment into bond_mii_monitor(), but it still relies
> on the return value of bond_miimon_inspect() as the hint. We need to return
> non-zero as long as we propose a link status change.
> 
> Fixes: de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
> Reported-by: Benjamin Gilbert <benjamin.gilbert@coreos.com>
> Tested-by: Benjamin Gilbert <benjamin.gilbert@coreos.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
