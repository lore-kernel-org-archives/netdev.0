From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: systemport: Fix 64-bit stats deadlock
Date: Fri, 15 Sep 2017 14:53:02 -0700 (PDT)
Message-ID: <20170915.145302.1071173348473883502.davem@davemloft.net>
References: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com>
        <20170915.142511.221689318302073484.davem@davemloft.net>
        <C414D433-28B3-4BA4-938B-B5C868918532@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jqiaoulk@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751230AbdIOVxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:53:02 -0400
In-Reply-To: <C414D433-28B3-4BA4-938B-B5C868918532@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Sep 2017 14:28:40 -0700

> FYI, there is another patch needed to ensure consistency between
> ethtool reported stats and netdevice stats, will submit that after
> some more testing. Thanks!

Yes, I saw that, th anks.
