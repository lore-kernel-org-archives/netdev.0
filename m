From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH 4/4] net/mlx4_en: Use atomic counter to decide when
 queue is full
Date: Mon, 25 Jun 2012 13:06:06 +0000
Message-ID: <953B660C027164448AE903364AC447D2868104FE@MTLDAG02.mtl.com>
References: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
	<1340270358-19504-5-git-send-email-yevgenyp@mellanox.co.il>
 <20120622.172353.1092394608024377078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:57277 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756429Ab2FYNIk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 09:08:40 -0400
In-Reply-To: <20120622.172353.1092394608024377078.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The Transmit and transmit completion flows execute from different
> > contexts, which are not synchronized. Hence naive reading the of
> > consumer index might give wrong value by the time it is being used, That could lead to a state of transmit timeout.
> > Fix that by using atomic variable to maintain that index.
> >
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> I'm not convinced.  There is only one place that actually changes the counter.
> 
> So it seems more like you have a missing memory barrier somewhere.
> 
> Other drivers do not need to use something as expansive as an atomic
> variable for this and neither should you.
> 
> I'm not applying this patch series, you'll need to resubmit it in it's
> entirety once you fix this patch.

Thanks,
I'll resubmit the other 3 and continue to work on this one.

Thanks,
Yevgeny
