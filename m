From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] iproute2: lib/utils.c bug fixes
Date: Sun, 14 Apr 2013 15:22:41 -0400 (EDT)
Message-ID: <20130414.152241.2174877623839388661.davem@davemloft.net>
References: <516AB8EE.5090901@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: mr.dash.four@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474Ab3DNTWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:22:43 -0400
In-Reply-To: <516AB8EE.5090901@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dash Four <mr.dash.four@googlemail.com>
Date: Sun, 14 Apr 2013 15:10:54 +0100

> This patch fixes the following 3 bugs in get_u32/get_u64 functions:
> 
>  1. On 32-bit systems, get_u32 could not detect an overflow.
>     get_u32(&l, "4294967296", 10) always returned 4294967295
>     (ULONG_MAX on 32-bit systems).
> 
>  2. get_u64(&ll, "4294967295", 10) was returning an error where
>     it shouldn't have (4294967295 is perfectly legitimate value for
>     unsigned long long).
> 
>  3. get_u64 couldn't detect an overflow errors (arg > ULLONG_MAX)
> 
> Changelog:
> 
> v2 - Dropped name title from Developer Certificate of Origin
> 
> Signed-off-by: Dash Four <mr.dash.four@googlemail.com>

Stephen already reimplmeneted your fixes in a slightly different
way.
