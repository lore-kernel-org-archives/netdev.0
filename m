From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] rps: Look into tunnels to get hash
Date: Thu, 19 May 2011 16:19:21 -0400 (EDT)
Message-ID: <20110519.161921.1673981736371153720.davem@davemloft.net>
References: <alpine.DEB.2.00.1105190833050.13026@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933926Ab1ESUTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:19:25 -0400
In-Reply-To: <alpine.DEB.2.00.1105190833050.13026@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 19 May 2011 08:38:57 -0700 (PDT)

> The patches in this series are to look into encapsulated packets
> to compute the rx hash for RPS.  Before these patches, all packets
> received on the same tunnel would wind up on the same RPS CPU-- this
> can lead to very poor loading, and make RFS ineffective on these
> packets.
> 
> This patch supports getting the rxhash out of a GRE encapsulated packet.

Series applied, thanks.
