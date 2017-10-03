From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: core: decouple ifalias get/set from
 rtnl lock
Date: Tue, 03 Oct 2017 15:55:38 -0700 (PDT)
Message-ID: <20171003.155538.1199302288435061105.davem@davemloft.net>
References: <20171002215005.10417-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdJCWzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:55:39 -0400
In-Reply-To: <20171002215005.10417-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  2 Oct 2017 23:50:05 +0200

> Device alias can be set by either rtnetlink (rtnl is held) or sysfs.
> 
> rtnetlink hold the rtnl mutex, sysfs acquires it for this purpose.
> Add an extra mutex for it and use rcu to protect concurrent accesses.
> 
> This allows the sysfs path to not take rtnl and would later allow
> to not hold it when dumping ifalias.
> 
> Based on suggestion from Eric Dumazet.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
