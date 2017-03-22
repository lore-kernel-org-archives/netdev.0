From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Add sysctl for minimum prefix len
 acceptable in RIOs.
Date: Wed, 22 Mar 2017 14:21:06 -0700 (PDT)
Message-ID: <20170322.142106.1607838051053330169.davem@davemloft.net>
References: <20170322091904.73420-1-jscherpelz@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, ek@google.com,
        lorenzo@google.com
To: jscherpelz@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdCVV25 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:28:57 -0400
In-Reply-To: <20170322091904.73420-1-jscherpelz@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joel Scherpelz <jscherpelz@google.com>
Date: Wed, 22 Mar 2017 18:19:04 +0900

> This commit adds a new sysctl accept_ra_rt_info_min_plen that
> defines the minimum acceptable prefix length of Route Information
> Options. The new sysctl is intended to be used together with
> accept_ra_rt_info_max_plen to configure a range of acceptable
> prefix lengths. It is useful to prevent misconfigurations from
> unintentionally blackholing too much of the IPv6 address space
> (e.g., home routers announcing RIOs for fc00::/7, which is
> incorrect).
> 
> Signed-off-by: Joel Scherpelz <jscherpelz@google.com>

Applied, thank you.
