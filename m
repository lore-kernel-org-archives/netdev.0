From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Do you guys think add link test to offline test is reasonable?
Date: Mon, 26 Aug 2013 10:17:20 +0100
Message-ID: <1377508640.16071.2.camel@deadeye.wl.decadent.org.uk>
References: <CAOhdcN_QPtfQK87LCmoS2k=7_W9Wzwke21PdvZUi9znZ3Si54Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hui-Zhi Zhao <zhaohuizhi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12832 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756560Ab3HZJR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 05:17:27 -0400
In-Reply-To: <CAOhdcN_QPtfQK87LCmoS2k=7_W9Wzwke21PdvZUi9znZ3Si54Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-26 at 15:47 +0800, Hui-Zhi Zhao wrote:
> Hi Guys,
> 
> 
> I have a query about the ethtool offline test.
> 
> 
> From the man page of "ethtool" I see the offline test should be
> "offline (default) means to perform full set of tests possibly causing
> normal operation interruption during the tests". In my opinion, it
> should just do something like inner loopback tests, offline should be
> no relative with live network connection.

I agree that an offline test should not depend on having a network link.

> Since it is impractical to expect these ports to be connected to a
> live network during production test (due to  limited network
> resources, a machine maybe have lots of ports), some of the tests will
> fail, even the cards have no problem.
>
> So, do you guys think add link test to offline test is reasonable?

You can do it but it shouldn't affect the overall pass/fail result.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
