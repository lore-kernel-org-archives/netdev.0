From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate
 counters for bps
Date: Mon, 18 May 2009 19:27:29 -0700 (PDT)
Message-ID: <20090518.192729.151565845.davem@davemloft.net>
References: <20090518172349.GA2755@ami.dom.local>
	<20090518.145233.212710505.davem@davemloft.net>
	<4A11F67B.3050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, vexwek@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, devik@cdi.cz
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752665AbZESC1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:27:31 -0400
In-Reply-To: <4A11F67B.3050805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 19 May 2009 01:59:55 +0200

> Sure, here it is.

Applied, thanks!

> We might need a similar patch to get a correct pps value
> too, since we currently are limited to ~ 2^21 packets per second.

True, but it is a less urgent issue than bps overflow.
