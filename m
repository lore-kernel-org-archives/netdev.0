From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] drivers: net: Fix 64-bit statistics seqcount
 init
Date: Tue, 01 Aug 2017 20:06:47 -0700 (PDT)
Message-ID: <20170801.200647.12058294195632848.davem@davemloft.net>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdHBDGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 23:06:50 -0400
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  1 Aug 2017 12:11:05 -0700

> This patch series fixes a bunch of drivers to have their 64-bit statistics
> seqcount cookie be initialized correctly. Most of these drivers (except b44,
> gtp) are probably used on 64-bit only hosts and so the lockdep splat might have
> never been seen.

Series applied, thanks.
