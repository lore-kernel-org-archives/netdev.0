From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix the use of pcpu_tstats in ip6_vti.c
Date: Thu, 02 Jan 2014 19:37:57 -0500 (EST)
Message-ID: <20140102.193757.1196904087317455511.davem@davemloft.net>
References: <1388643876-31865-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaACAh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:37:58 -0500
In-Reply-To: <1388643876-31865-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  2 Jan 2014 14:24:36 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when read/write the 64bit data, the correct lock should be hold.
> and we can use the generic vti6_get_stats to return stats, and
> not define a new one in ip6_vti.c
> 
> Fixes: 87b6d218f3adb ("tunnel: implement 64 bits statistics")
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
