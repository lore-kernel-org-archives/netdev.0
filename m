From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 01:46:01 +0400
Message-ID: <20060918214601.GA14322@ms2.inr.ac.ru>
References: <20060918162847.GA4863@ms2.inr.ac.ru> <200609181850.22851.ak@suse.de> <20060918210321.GA4780@ms2.inr.ac.ru> <20060918.142247.14844785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, master@sectorb.msk.ru, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:11440 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751923AbWIRVqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 17:46:16 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060918.142247.14844785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Ok, ok, but don't we have queueing disciplines that need the timestamp
> even on ingress?

I cannot find.

ip_queue does. But it is just another user, not different of sockets.

BTW in any case, any user of timestamp who sees 0, because skb was received
before timestamping was enabled, has to calculate timestamp itself right
in the place where Andi suggested. Seems, preparation to the change
makes sense even without the change. :-)

Alexey

