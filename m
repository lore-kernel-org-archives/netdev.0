From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 19:15:08 -0500 (EST)
Message-ID: <20140224.191508.199622728478930062.davem@davemloft.net>
References: <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	<1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140224155130.4c286cca@samsung-9>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ja@ssi.bg, ycheng@google.com,
	netdev@vger.kernel.org, ncardwell@google.com, brakmo@google.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbaBYAPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:15:10 -0500
In-Reply-To: <20140224155130.4c286cca@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 24 Feb 2014 15:51:30 -0800

> The original reason I kept ms resolution and added the flag was
> that accessing high resolution time is expensive for systems where
> TSC is not stable.  Google may live in a world of SMP systems with
> good X86 CPUs with working TSC, but other architectures and system
> config's may have non-working TSC.

+1
