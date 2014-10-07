From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: bcmgenet: fix Tx ring priority
 programming
Date: Tue, 07 Oct 2014 13:09:13 -0400 (EDT)
Message-ID: <20141007.130913.333160766392432507.davem@davemloft.net>
References: <20141007163001.85125100761@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbaJGRJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:09:15 -0400
In-Reply-To: <20141007163001.85125100761@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Tue,  7 Oct 2014 09:30:01 -0700 (PDT)

> GENET MAC has three Tx ring priority registers:
> - GENET_x_TDMA_PRIORITY0 for queues 0-5
> - GENET_x_TDMA_PRIORITY1 for queues 6-11
> - GENET_x_TDMA_PRIORITY2 for queues 12-16
> 
> Fix bcmgenet_init_multiq() to program them correctly.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Yeah this looks a lot nicer, applied, thanks!
