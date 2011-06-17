From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: rfs: enable RFS before first data packet is
 received
Date: Fri, 17 Jun 2011 15:27:50 -0400 (EDT)
Message-ID: <20110617.152750.246351152745882198.davem@davemloft.net>
References: <1308268246.2925.37.camel@bwh-desktop>
	<20110616.233841.1893411919443027926.davem@davemloft.net>
	<1308318315.2780.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab1FQT17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:27:59 -0400
In-Reply-To: <1308318315.2780.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Jun 2011 15:45:15 +0200

> [PATCH v2] net: rfs: enable RFS before first data packet is received
> 
> First packet received on a passive tcp flow is not correctly RFS
> steered.
> 
> One sock_rps_record_flow() call is missing in inet_accept()
> 
> But before that, we also must record rxhash when child socket is setup.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
