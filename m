From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dev: advertise the new nsid when the netns
 iface changes
Date: Wed, 04 Oct 2017 18:05:00 -0700 (PDT)
Message-ID: <20171004.180500.2303647937190147725.davem@davemloft.net>
References: <52f84baf-8027-d01f-8ece-db4f39a2f76f@6wind.com>
        <20171003115323.21388-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason@zx2c4.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbdJEBFB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 21:05:01 -0400
In-Reply-To: <20171003115323.21388-1-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  3 Oct 2017 13:53:23 +0200

> x-netns interfaces are bound to two netns: the link netns and the upper
> netns. Usually, this kind of interfaces is created in the link netns and
> then moved to the upper netns. At the end, the interface is visible only
> in the upper netns. The link nsid is advertised via netlink in the upper
> netns, thus the user always knows where is the link part.
> 
> There is no such mechanism in the link netns. When the interface is moved
> to another netns, the user cannot "follow" it.
> This patch adds a new netlink attribute which helps to follow an interface
> which moves to another netns. When the interface is unregistered, the new
> nsid is advertised. If the interface is a x-netns interface (ie
> rtnl_link_ops->get_link_net is defined), the nsid is allocated if needed.
> 
> CC: Jason A. Donenfeld <Jason@zx2c4.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Ok, applied, thanks.
