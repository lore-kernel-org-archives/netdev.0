From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: mcast: fix br_multicast_dev_del warn
 when igmp snooping is not defined
Date: Mon, 20 Jul 2015 16:20:37 -0700 (PDT)
Message-ID: <20150720.162037.22945315511431028.davem@davemloft.net>
References: <201507210410.H5dNw6Lx%fengguang.wu@intel.com>
	<1437426225-28418-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756847AbbGTXUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 19:20:40 -0400
In-Reply-To: <1437426225-28418-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 20 Jul 2015 23:03:45 +0200

> Fix:
> net/bridge/br_if.c: In function 'br_dev_delete':
>>> net/bridge/br_if.c:284:2: error: implicit declaration of function
>>> 'br_multicast_dev_del' [-Werror=implicit-function-declaration]
>      br_multicast_dev_del(br);
>      ^
>    cc1: some warnings being treated as errors
> 
> when igmp snooping is not defined.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> Apologies for the mess.

Applied, thanks.
