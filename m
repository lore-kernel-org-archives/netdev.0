From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 05 Nov 2008 13:06:45 -0800
Message-ID: <49120AE5.302@hp.com>
References: <20081105114900.GA18691@ioremap.net>	<20081105.035454.87914782.davem@davemloft.net>	<Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>	<20081105.040943.03609283.davem@davemloft.net>	<Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>	<20081105130405.GA26435@ioremap.net>	<Pine.LNX.4.64.0811051527210.23792@wrl-59.cs.helsinki.fi>	<4911EA97.8080101@hp.com> <Pine.LNX.4.64.0811052108250.9159@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:5447 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbYKEVG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 16:06:57 -0500
In-Reply-To: <Pine.LNX.4.64.0811052108250.9159@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Ignoring the TSO case for a moment, if there is congestion and receiver 
>>window available and a user makes a > MSS send that isn't an integral 
>>multiple of the MSS, we don't delay the last subMSS segment do we?
> 
> 
> Without TSO, only Nagle could prevent sending that submss portion, so the 
> answer depends on what the window in-flight consists of.

I always thought that Nagle was supposed to be implemented as if it was 
on a user send() by user send() basis and not segment by segment, in 
which case no send() > MSS would be delayed by Nagle.

rick jones
