From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: gen_estimator: Fix signed integers
 right-shifts.
Date: Mon, 25 May 2009 22:47:16 -0700 (PDT)
Message-ID: <20090525.224716.01512521.davem@davemloft.net>
References: <20090519075715.GC4210@ff.dom.local>
	<4A12F46C.4070605@cosmosbay.com>
	<20090519190915.GC2981@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, vexwek@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, devik@cdi.cz
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651AbZEZFrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 01:47:16 -0400
In-Reply-To: <20090519190915.GC2981@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 19 May 2009 21:09:15 +0200

> pkt_sched: gen_estimator: Fix signed integers right-shifts.
> 
> Right-shifts of signed integers are implementation-defined so unportable.
> 
> With feedback from: Eric Dumazet <dada1@cosmosbay.com>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied to net-next-2.6, thanks!
