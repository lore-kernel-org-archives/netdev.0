From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [RFC] [GIT PATCH] IPv6 Routing / Ndisc Fixes
Date: Thu, 10 Aug 2006 13:20:32 +0300
Message-ID: <44DB0870.6000902@tcs.hut.fi>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>	<44D9D431.10101@tcs.hut.fi>	<44DA558A.1080706@tcs.hut.fi> <20060810.174635.42119608.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:49163 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1161145AbWHJKUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 06:20:34 -0400
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20060810.174635.42119608.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:

> As a result of original lookup (with possible ambiguous outout interface),
> one interface for original output is selected.
> Which means, we have a route for the (original) destination through that
> interface.
> 
> Redirects shall come from that interface.
> So, it is enough to lookup routes on that interface.

Yes, exactly.

Regards,
Ville
