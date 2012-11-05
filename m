From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: export IP6_RT_PRIO_* to userland
Date: Mon, 05 Nov 2012 12:00:17 -0500 (EST)
Message-ID: <20121105.120017.1189906314924845791.davem@davemloft.net>
References: <1352129298-1104-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab2KERAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 12:00:19 -0500
In-Reply-To: <1352129298-1104-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon,  5 Nov 2012 16:28:18 +0100

> The kernel uses some default metric when routes are managed. For example, a
> static route added with a metric set to 0 is inserted in the kernel with
> metric 1024 (IP6_RT_PRIO_USER).
> It is useful for routing daemons to know these values, to be able to set routes
> without interfering with what the kernel does.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

But these belong in the libc headers anyways.

If we haven't provided them for so long, there's no real value of
adding them now.
