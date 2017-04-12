From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: allow configuring default qdisc
Date: Tue, 11 Apr 2017 22:09:59 -0400 (EDT)
Message-ID: <20170411.220959.313852914647879245.davem@davemloft.net>
References: <20170408193946.18469-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38904 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdDLCKD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 22:10:03 -0400
In-Reply-To: <20170408193946.18469-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat,  8 Apr 2017 15:39:46 -0400

> Since 3.12 it has been possible to configure the default queuing
> discipline via sysctl. This patch adds ability to configure the
> default queue discipline in kernel configuration. This is useful for
> environments where configuring the value from userspace is difficult
> to manage.
> 
> The default is still the same as before (pfifo_fast) and it is
> possible to change after kernel init with sysctl. This is similar
> to how TCP congestion control works.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> v2 - rearrange order of menu items
>      use pfifo_fast not pfifo

Stephen I'm still thinking about this.

Normal users typing "make oldconfig" shouldn't be asked a question
like this.  They have no idea.  This is just like how we hide all the
advanced ipv4 routing choices behind the Kconfig symbol
IP_ADVANCED_ROUTER and TCP congestion control with TCP_CONG_ADVANCED.

And from experience I know that if it shows up when Linus types 'make'
after pulling this in, he will complain :-)
