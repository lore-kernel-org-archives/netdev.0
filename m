From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Thu, 09 Jun 2011 14:47:04 -0700 (PDT)
Message-ID: <20110609.144704.1705676110990397845.davem@davemloft.net>
References: <20110606085247.GE31505@secunet.com>
	<1307423217.2642.59.camel@edumazet-laptop>
	<20110608053020.GA6489@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611Ab1FIVrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 17:47:24 -0400
In-Reply-To: <20110608053020.GA6489@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 8 Jun 2011 07:30:20 +0200

> In between I can confirm that we get the slowpath problem back with my
> patch, so we still have a bug somewhere. Reverting your commit would
> be just a band aid. I think it is better to find the bug and do a real
> fix instead. Unfortunatly I fear I'm not able to track it down before
> my vacation that starts tomorrow. I'll continue to work at it once I'm
> back...

Thanks Steffen, looking forward to this.
