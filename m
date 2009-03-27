From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Plug sk_buff leak in ipv6_rcv (net/ipv6/ip6_input.c)
Date: Fri, 27 Mar 2009 00:18:30 -0700 (PDT)
Message-ID: <20090327.001830.126379447.davem@davemloft.net>
References: <20090326123853.GW31562@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mikael.starvik@axis.com
To: jesper.nilsson@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbZC0HSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:18:42 -0400
In-Reply-To: <20090326123853.GW31562@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Nilsson <jesper.nilsson@axis.com>
Date: Thu, 26 Mar 2009 13:38:53 +0100

> Commit 778d80be52699596bf70e0eb0761cf5e1e46088d
> (ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface)
> seems to have introduced a leak of sk_buff's for ipv6 traffic,
> at least in some configurations where idev is NULL, or when ipv6
> is disabled via sysctl.
 ...
> Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>

Applied and queued up for -stable, thanks!
