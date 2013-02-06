From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Don't send packet to big messages to
 self
Date: Wed, 06 Feb 2013 15:13:13 -0500 (EST)
Message-ID: <20130206.151313.500975643010954565.davem@davemloft.net>
References: <20130205114804.GH23291@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757046Ab3BFUNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:13:15 -0500
In-Reply-To: <20130205114804.GH23291@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 5 Feb 2013 12:48:05 +0100

> Calling icmpv6_send() on a local message size error leads to an
> incorrect update of the path mtu in the case when IPsec is used.
> So use ipv6_local_error() instead to notify the socket about the
> error.
> 
> Reported-by: Jiri Bohac <jbohac@suse.cz>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks a lot.
