From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 20:57:44 +0000
Message-ID: <1289422664.2249.1.camel@achroite.uk.solarflarecom.com>
References: <1289368423.2700.17.camel@edumazet-laptop>
	 <1289373771.2700.110.camel@edumazet-laptop>
	 <201011102325.JAF82308.OSVLFHtFJMQFOO@I-love.SAKURA.ne.jp>
	 <20101110.103923.59670339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:2502 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab0KJU5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 15:57:48 -0500
In-Reply-To: <20101110.103923.59670339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-10 at 10:39 -0800, David Miller wrote:
[...]
> In this patch, I use a bitmap (a single long var) so that only filters
> using mem[] loads/stores pay the price of added security checks.
> 
> For other filters, additional cost is a single instruction.
> 
> [ Since we access fentry->k a lot now, cache it in a local variable
>   and mark filter entry pointer as const. -DaveM ]
[...]

I don't see the justification for combining these changes.  One patch,
one fix, right?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

