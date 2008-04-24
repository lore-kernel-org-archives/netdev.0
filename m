From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK]: Fix bogus ASSERT_RTNL warning
Date: Wed, 23 Apr 2008 22:11:42 -0700 (PDT)
Message-ID: <20080423.221142.169307866.davem@davemloft.net>
References: <48100203.2020606@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750860AbYDXFLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 01:11:44 -0400
In-Reply-To: <48100203.2020606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 24 Apr 2008 05:44:03 +0200

> This patch should fix/silence the warning reported by Denys
> Fedoryshchenko. Looking at kerneloops.org, there are also a
> huge number of reports of this warning triggered by wireless,
> so even if this is not the ideal solution, I think for now
> we should just silence it.

Thanks Patrick, I'll probably send this to -stable too.

We can handle this more elegantly with followon patches
if we want.
