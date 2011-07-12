From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw
 ethernet socket interface
Date: Tue, 12 Jul 2011 00:19:53 -0700 (PDT)
Message-ID: <20110712.001953.709404117315345178.davem@davemloft.net>
References: <20110711.202717.1764669415135298036.davem@davemloft.net>
	<CAMJ=MEf8KkNNSvHy-pepg_GfkrnquKo+zW3GyB7RDAYO2H+SVA@mail.gmail.com>
	<1310453928.2860.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ronny.meeus@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab1GLHT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 03:19:58 -0400
In-Reply-To: <1310453928.2860.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Jul 2011 08:58:48 +0200

> This seems a bug, but in softirq handling in your arch

That's not the problem, it's the dev_queue_xmit_nit() code
path that interrupt is interrupting.
