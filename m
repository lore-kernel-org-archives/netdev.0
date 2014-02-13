From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next V2] gre: return more precise errno value when
 adding tunnel fails
Date: Thu, 13 Feb 2014 18:45:25 -0500 (EST)
Message-ID: <20140213.184525.1491360161780549632.davem@davemloft.net>
References: <1392281915-29075-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbaBMXp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:45:27 -0500
In-Reply-To: <1392281915-29075-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 13 Feb 2014 09:58:35 +0100

> Currently this always returns ENOBUFS, because the return value of
> __ip_tunnel_create is discarded.
> 
> A more common failure is a duplicate name (EEXIST).  Propagate the real
> error code so userspace can display a more meaningful error message.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

This isn't a change to the GRE code, it's a change to the generic ipv4
tunneling support layer.  Please update your Subject to match.

Thanks.
