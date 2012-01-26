From: Rune Magnussen <rum@bankdata.dk>
Subject: Re: [BISECTED] Linux 3.2: Networking out of LAN does not work
Date: Thu, 26 Jan 2012 08:55:15 +0100
Message-ID: <OF622688C3.48635D7E-ONC1257991.002B0EF8-C1257991.002B82CA@bdpnet.dk>
References: <20120125.214146.1725158231070595211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.bankdata.dk ([194.239.188.13]:40099 "HELO mx4.bankdata.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751242Ab2AZHzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:55:23 -0500
In-Reply-To: <20120125.214146.1725158231070595211.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 25 Jan 2012 12:05:31 +0100

>> OK please test the following patch.
>> 
>> [PATCH] net: use index hash for /proc/net/dev

> Sorry, we never promised to list devices in any particular order,
> any such dependency is a bug and must be fixed instead of papered
> around by the kernel.

OK. I simply asumed it was a kernel issue since it started after an 
upgrade.
Now at lest I have an idea about where to look.

Greetings Rune
