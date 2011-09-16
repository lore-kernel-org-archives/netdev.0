From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH] ipv6: Send ICMPv6 RSes only when RAs are accepted
Date: Sat, 17 Sep 2011 00:07:45 +0200
Message-ID: <4E73C8B1.70404@fud.no>
References: <201108291209.p7TC9KkD002967@wrath.fud.no> <20110916.171503.42153974977438913.davem@davemloft.net> <4E73C2E5.2050901@fud.no> <20110916.174900.961553137813655280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:60574 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932091Ab1IPWHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 18:07:46 -0400
In-Reply-To: <20110916.174900.961553137813655280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller

>> I'm not removing accept_ra==2, no, only forwarding==2. Or, more
>> precisely, I'm only removing the *documentation* for forwarding==2;
>> forwarding==2 will still work, but there's no difference from
>> forwarding==1 any longer.
> 
> Ok, please make this more clear in your commit message.

I actually did improve the commit message in this regard when I re-sent
the patch, see <http://patchwork.ozlabs.org/patch/113625/>. Is that one
good enough?

-- 
Tore Anderson
