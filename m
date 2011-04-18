From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/42] Kill -Wunused-but-set warnings
Date: Mon, 18 Apr 2011 03:19:15 +0100
Message-ID: <1303093155.5282.1009.camel@localhost>
References: <20110417.173233.193710905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14458 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1DRCTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 22:19:18 -0400
In-Reply-To: <20110417.173233.193710905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-17 at 17:32 -0700, David Miller wrote:
> The weather is real nice, so I decided to lock myself inside and
> fix compiler warnings.
> 
> I started using gcc-4.6.x on my primary sparc64 build test machine the
> other week and it now enables -Wunused-but-set with -Wall and it does
> catch a bunch of bogus stuff.
[...]

In most of these cases there is presumably no need for the variable at
all.  In others, the variable should have been used - which I believe is
the main reason for the warning - and by removing it you will be hiding
a bug.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

