From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6 addrconf: revert /proc/net/if_inet6
 ifa_flag format
Date: Tue, 10 Dec 2013 13:52:40 -0500 (EST)
Message-ID: <20131210.135240.205102619455114579.davem@davemloft.net>
References: <1386680189-7852-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	alex.aring@gmail.com, florent.fourcot@enst-bretagne.fr
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab3LJSwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:52:43 -0500
In-Reply-To: <1386680189-7852-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 10 Dec 2013 13:56:29 +0100

> Turned out that applications like ifconfig do not handle the change.
> So revert ifa_flag format back to 2-letter hex value.
> 
> Introduced by:
> commit 479840ffdbe4242e8a25349218c8e0859223aa35
>     "ipv6 addrconf: extend ifa_flags to u32"
> 
> Reported-by: Alexander Aring <alex.aring@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
