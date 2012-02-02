From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Thu, 02 Feb 2012 19:37:53 +0100
Message-ID: <4F2AD801.1010409@profihost.ag>
References: <4F26E72E.2020007@profihost.ag> 	<20120130.164828.1695146432151008554.davem@davemloft.net> 	<4F27A18F.3060907@profihost.ag>  <20120201.162157.880976652659067010.davem@davemloft.net>  <4F2A87B0.6070900@profihost.ag> <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, greg@kroah.com,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:41934 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526Ab2BBShz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 13:37:55 -0500
In-Reply-To: <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

Am 02.02.2012 16:04, schrieb Eric Dumazet:
> Hmm, thats a problem, we need a stable 3.0 kernel for sure.
>
> Should distros handle this tricky problem themselves ?
>
> I tried to find a solution, but we had so many changes in this part of
> the code that its really hard.
>
> I see 3 ways :
>
> 1) Warn the world 3.0 is unfixable and should be avoided.
>     Ask stable team to instead support 3.1 or 3.2
>
> 2) Disable redirects on 3.0
>
> 3) Maybe try to revert f39925dbde77
>
> (ipv4: Cache learned redirect information in inetpeer.)
>
> Unfortunately this was introduced in 2.6.39, and it seems trying to
> revert it on 3.0 tree is not trivial.

as the stable maintainer. What's your opinion?

Stefan
