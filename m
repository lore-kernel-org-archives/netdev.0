From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next2.6] drivers/net: more return operator cleanup
Date: Fri, 24 Sep 2010 19:56:43 -0700 (PDT)
Message-ID: <20100924.195643.232749643.davem@davemloft.net>
References: <1285256409.2509.79.camel@edumazet-laptop>
	<1285373014.11616.194.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753270Ab0IYC4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 22:56:23 -0400
In-Reply-To: <1285373014.11616.194.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 24 Sep 2010 17:03:34 -0700

> Change "return (EXPR);" to "return EXPR;"
> 
> return is not a function, parentheses are not required.
> 
> drivers/net/wireless excluded.
> Most whitespace errors on same line as return fixed.
> 
> Done via script with some manual multi-line aligning.
> Compile tested x86 only, not all files compiled.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Joe, you're really starting to tick me off.

Why in the world are you subsuming this set of changes which Eric
Dumazet has already made already, and on top of it not giving him any
credit in the commit message?

And you're doing this after bugging the crap out of me by asking me to
hurry up with applying Eric's patch in a totally inappropriate private
email?

You have to be joking.

Look, if there is anything in my queue in patchwork, it means I am
backlogged.

And when I'm backlogged I prioritize.  And how I prioritize to get my
head back above water and on top of the queue again is my business.

The last thing you should do is try to preempt other things like
important crash fixes by asking me to hurry up with a cleanup
patch.
