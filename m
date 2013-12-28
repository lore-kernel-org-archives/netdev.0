From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: ping make local stuff static
Date: Sat, 28 Dec 2013 17:06:47 -0500 (EST)
Message-ID: <20131228.170647.760559988054320727.davem@davemloft.net>
References: <20131228111142.6fcc0234@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab3L1WGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 17:06:48 -0500
In-Reply-To: <20131228111142.6fcc0234@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 28 Dec 2013 11:11:42 -0800

> Don't export ping_table or ping_v4_sendmsg. Both are only used
> inside ping code.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

ping_v4_sendmsg was meant to be used by ping_v6_sendmsg in order to
support ipv4 mapped ipv6 addresses, currently it just returns
-EINVAL.

But yeah, that never happened.

Applied, thanks.
