From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: multicast: start querier timer
 when running user-space stp
Date: Tue, 23 Jun 2015 03:31:02 -0700 (PDT)
Message-ID: <20150623.033102.2148484981874714822.davem@davemloft.net>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	herbert@gondor.apana.org.au, sashok@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbbFWKTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 06:19:12 -0400
In-Reply-To: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 19 Jun 2015 01:45:50 -0700

> When STP is running in user-space and querier is configured, the
> querier timer is not started when a port goes to a non-blocking state.
> This patch unifies the user- and kernel-space stp multicast port enable
> path and enables it in all states different from blocking. Note that when a
> port goes in BR_STATE_DISABLED it's not enabled because that is handled
> in the beginning of the port list loop.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2: Repurposed for net-next and implemented Herbert's suggestion for
>     unifying both user- and kernel-space multicast enable port paths.

Applied.
