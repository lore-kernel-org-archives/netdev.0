From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] ipvs: Create synced connections with their real
 state
Date: Mon, 19 Nov 2007 21:53:45 -0800 (PST)
Message-ID: <20071119.215345.260724818.davem@davemloft.net>
References: <20071114182439.821730508@natsuko.shinjuku.tokyo.vergenet.net>
	<20071114182720.091263955@natsuko.shinjuku.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg,
	jmack@wm7d.net, graeme@graemef.net, rumen@voicecho.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753492AbXKTFxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:53:46 -0500
In-Reply-To: <20071114182720.091263955@natsuko.shinjuku.tokyo.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 10:24:41 -0800

> With this patch the synced connections are created with their real state,
> which can be changed on the next synchronizations if necessary. This way 
> on fail-over all the connections will be treated according to their actual
> state, causing no scheduling problems (the active and the nonactive 
> connections have different weights in the schedulers). 
> The backwards compatibility is preserved and the existing tools will show
> the true connection states even on the backup director. 
>  
> Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Also applied to net-2.6.25, thanks!
