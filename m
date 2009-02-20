From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gre: used time_before for comparing jiffies
Date: Fri, 20 Feb 2009 00:45:13 -0800 (PST)
Message-ID: <20090220.004513.117109293.davem@davemloft.net>
References: <20090220.000133.175557384.davem@davemloft.net>
	<20090220083935.GA18673@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbZBTIpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:45:32 -0500
In-Reply-To: <20090220083935.GA18673@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 20 Feb 2009 16:39:35 +0800

> So assuming that IPTUNNEL_ERR_TIMEO > 0, then the macro version
> wraps around after the open-coded version, which would seem to
> mean that it's better, no?

Seems that way...

Let me see if I can find Alexey's email where he explains
all of this.  I really don't want to touch these things
without being able to read that again.

If anyone else can find his posting about this stuff from
years ago, please post the link.

Thanks.
