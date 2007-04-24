From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 16:22:03 -0700 (PDT)
Message-ID: <20070424.162203.41947944.davem@davemloft.net>
References: <20070424145754.1a37f666@dxpl.pdx.osdl.net>
	<1177452915.30986.61.camel@localhost.localdomain>
	<20070425.074932.51286377.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, shemminger@linux-foundation.org,
	dada1@cosmosbay.com, bunk@stusta.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754650AbXDXXV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 19:21:56 -0400
In-Reply-To: <20070425.074932.51286377.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 25 Apr 2007 07:49:32 +0900 (JST)

> [TCP]: Fix linkage errors on i386.
> 
> To avoid raw division, use ktime_to_timeval() to get usec.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

This one looks good to me, patch applied.

Thanks.
