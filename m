From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6: Fix build error with udp_offload
Date: Thu, 15 Nov 2012 22:49:14 -0500 (EST)
Message-ID: <20121115.224914.221499324977781840.davem@davemloft.net>
References: <50a584d5.9dutnkC1pLuFHpWQ%fengguang.wu@intel.com>
	<1353033337-2772-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab2KPDtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 22:49:15 -0500
In-Reply-To: <1353033337-2772-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 15 Nov 2012 21:35:37 -0500

> Add ip6_checksum.h include.  This should resolve the following issue
> that shows up on power:
> 
> net/ipv6/udp_offload.c: In function 'udp6_ufo_send_check':
> net/ipv6/udp_offload.c:29:2: error: implicit declaration of function
> 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.
