From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS)
 returns -1
Date: Tue, 12 Dec 2006 17:11:21 -0800 (PST)
Message-ID: <20061212.171121.21596915.davem@davemloft.net>
References: <457DD3EB.9030201@hp.com>
	<200612120908.19378@auguste.remlab.net>
	<457F1C2B.9000800@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdenis@simphalempin.com, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932318AbWLMBcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 20:32:15 -0500
To: brian.haley@hp.com
In-Reply-To: <457F1C2B.9000800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 12 Dec 2006 16:16:27 -0500

> The following patch seems to work for me, but this code has behaved this 
> way for a while, so don't know if it will break any existing apps.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

I like this patch so I have applied it, thanks Brian.  I'll
push it to -stable too.

I wonder, since the most accurate return value is tied to the route,
what is expected of this getsockopt() before a socket's identity
(and therefore route) is known?

I suppose returning the default value, which Brian's patch does,
is a reasonable best-effort.
