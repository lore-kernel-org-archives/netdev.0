From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: add changelink support
Date: Tue, 21 Feb 2017 12:19:56 -0500 (EST)
Message-ID: <20170221.121956.630133467702920098.davem@davemloft.net>
References: <1487608159-970-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        jbenc@redhat.com, pshelar@ovn.org, joe@ovn.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55304 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753996AbdBURT7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:19:59 -0500
In-Reply-To: <1487608159-970-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon, 20 Feb 2017 08:29:19 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds changelink rtnl op support for vxlan netdevs.
> code changes involve:
>     - refactor vxlan_newlink into vxlan_nl2conf to be
>     used by vxlan_newlink and vxlan_changelink
>     - vxlan_nl2conf and vxlan_dev_configure take a
>     changelink argument to isolate changelink checks
>     and updates.
>     - Allow changing only a few attributes:
>         - return -EOPNOTSUPP for attributes that cannot
>         be changed for now. Incremental patches can
>         make the non-supported one available in the future
>         if needed.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
