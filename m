From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next V3] ip_tunnel: return more precise errno value
 when adding tunnel fails
Date: Mon, 17 Feb 2014 00:07:42 -0500 (EST)
Message-ID: <20140217.000742.2266454591904373167.davem@davemloft.net>
References: <1392380079-3226-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaBQFHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:07:43 -0500
In-Reply-To: <1392380079-3226-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 14 Feb 2014 13:14:39 +0100

> Currently this always returns ENOBUFS, because the return value of
> __ip_tunnel_create is discarded.
> 
> A more common failure is a duplicate name (EEXIST).  Propagate the real
> error code so userspace can display a more meaningful error message.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
