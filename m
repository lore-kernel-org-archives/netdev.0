From: Patrick McHardy <kaber@trash.net>
Subject: Re: Yet another bridge netfilter crash
Date: Fri, 23 Jul 2010 17:17:42 +0200
Message-ID: <4C49B296.10009@trash.net>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39971 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759921Ab0GWPRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 11:17:36 -0400
In-Reply-To: <20100723150041.GA7301@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.07.2010 17:00, Herbert Xu wrote:
> On Fri, Jul 23, 2010 at 04:18:46PM +0200, Patrick McHardy wrote:
>>
>> I think we've already fixed this by commit 8fa9ff6:
>>
> 
>> commit 8fa9ff6849bb86c59cc2ea9faadf3cb2d5223497
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Tue Dec 15 16:59:59 2009 +0100
>>
>>     netfilter: fix crashes in bridge netfilter caused by fragment jumps
> 
> Thanks for the pointer Patrick.
> 
> Your memory is much better than mine, as I was in that thread too :)
> 
> BTW, do you have any plans on addressing the deeper issue of
> separating the connection tracking as well?

No concrete plans yet, but its something I'm definitely planning
to try at some point.

> There's also the matter of fragments jumping between bridges.

Conntrack zones can be used to avoid that, but that currently needs
manual configuration.
