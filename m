From: David Miller <davem@davemloft.net>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 04 Dec 2008 12:47:47 -0800 (PST)
Message-ID: <20081204.124747.89999526.davem@davemloft.net>
References: <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
	<20081204.115416.174997306.davem@davemloft.net>
	<b98e548c0812041205y4538b62apbbdb42469220ffa9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ldecicco@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: saverio.mascolo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754698AbYLDUrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:47:46 -0500
In-Reply-To: <b98e548c0812041205y4538b62apbbdb42469220ffa9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Date: Thu, 4 Dec 2008 21:05:37 +0100

> > The bigger problem is that windows are so much larger now that going
> > back to the stone ages and newreno recovery behavior is absolutely not
> > an option any more.
> 
> average window cannot be much larger, because average windows  follow
> network capacity in any case. so you can end up having only more
> oscillating windows (i.e. more timeouts, more retransmissions)

But a lost based fast recovery is more expensive unless you
modify the congestion window handling, reno simply does
not scale.
