From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Mon, 11 Jun 2012 04:20:24 -0700 (PDT)
Message-ID: <20120611.042024.1022194952800114410.davem@davemloft.net>
References: <20120611.022911.885347106959530782.davem@davemloft.net>
	<20120611111659.GK27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab2FKLUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 07:20:24 -0400
In-Reply-To: <20120611111659.GK27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 11 Jun 2012 13:16:59 +0200

> It seems that we don't cache the learned pmtu informations
> in some cases with ip_rt_frag_needed() removed. 

We need to find a way to implement this then, in such a way
that we have the route context used to send the ping packet
out.

Otherwise, it's impossible to record the information properly.
