From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns
 -1
Date: Wed, 13 Dec 2006 12:28:47 -0500
Message-ID: <4580384F.4070904@hp.com>
References: <457DD3EB.9030201@hp.com>	<200612120908.19378@auguste.remlab.net>	<457F1C2B.9000800@hp.com> <20061212.171121.21596915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdenis@simphalempin.com, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:49620 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932655AbWLMRyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:54:52 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061212.171121.21596915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I wonder, since the most accurate return value is tied to the route,
> what is expected of this getsockopt() before a socket's identity
> (and therefore route) is known?

A search for RTAX_HOPLIMIT found very little code that ever sets it, 
iproute2 was the only important one, so the interface/system default is 
probably the only one that's ever used.

-Brian
