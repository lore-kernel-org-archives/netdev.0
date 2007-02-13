From: Baruch Even <baruch@ev-en.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 22:06:00 +0200
Message-ID: <20070213200600.GU25760@galon.ev-en.org>
References: <20070212221241.GQ25760@galon.ev-en.org> <20070212.145351.35661569.davem@davemloft.net> <20070213095613.GR25760@galon.ev-en.org> <20070213.115636.74561887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:11979
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbXBMUGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:06:04 -0500
Content-Disposition: inline
In-Reply-To: <20070213.115636.74561887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070213 21:56]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Tue, 13 Feb 2007 11:56:13 +0200
> 
> > Do you still think that making Cubic the default is a good idea?
> 
> Can you propose a better alternative other than Reno?

The only other option would be HS-TCP. It is a very simple extension of
Reno and should be good enough for the current common high BDP
connections. If not that then the choice is to keep on BIC and test the
existing implementation of Cubic before making it the default, if at
all.

I still think that using a default of high-speed algorithm is not the
right thing to do, but I'd rather have a sane default rather than go for
the latest proposal to catch the eye.

Baruch
