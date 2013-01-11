From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours
 on fib GC
Date: Fri, 11 Jan 2013 15:50:38 -0800 (PST)
Message-ID: <20130111.155038.1606083912179468348.davem@davemloft.net>
References: <1357753459-12872-1-git-send-email-roland@kernel.org>
	<20130110.141847.265135906896223944.davem@davemloft.net>
	<CAL1RGDVjwddbyVdkzMeXEiqFXQNECjCWAyEFK5V5oAPddfbwZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab3AKXuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 18:50:39 -0500
In-Reply-To: <CAL1RGDVjwddbyVdkzMeXEiqFXQNECjCWAyEFK5V5oAPddfbwZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Fri, 11 Jan 2013 13:13:42 -0800

> In the meantime does it make sense to put a smaller bandaid in 3.8?

I want it fixed properly from the start, sorry.

> I'm pretty sure this is a regression (we never saw it with older
> kernels), probably due to some part of the route cache improvements
> you've been doing.

I do not believe this is the situation at all.
