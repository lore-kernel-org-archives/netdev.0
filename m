From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Convert the normal transmit complete
 path to dev_consume_skb_any()
Date: Tue, 09 Sep 2014 16:46:24 -0700 (PDT)
Message-ID: <20140909.164624.687652552683224035.davem@davemloft.net>
References: <20140909214327.D474F290042C@tardy>
	<1410304704.7106.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<540F8F78.9020502@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, raj@tardy.usa.hp.com,
	netdev@vger.kernel.org, sshah@solarflare.com,
	linux-net-drivers@solarflare.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbaIIXqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:46:25 -0400
In-Reply-To: <540F8F78.9020502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 09 Sep 2014 16:38:32 -0700

> But perhaps someone from SolarFlare can say why that was a const to
> begin with.

Probably to trap skb->x modifications after the SKB has been placed
in these entries, except for these explicit spots where the casts
are applied.
