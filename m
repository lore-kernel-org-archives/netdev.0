From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] Subject: net: allow configuring default
 qdisc
Date: Mon, 17 Apr 2017 13:23:34 -0400 (EDT)
Message-ID: <20170417.132334.115578439906533319.davem@davemloft.net>
References: <20170413154053.27568-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752180AbdDQRXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:23:39 -0400
In-Reply-To: <20170413154053.27568-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 13 Apr 2017 08:40:53 -0700

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
> v2 -- add another level of indirection to make it easier for
>       users blindly doing make oldconfig

Applied, thanks.
