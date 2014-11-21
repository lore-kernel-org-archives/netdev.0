From: David Miller <davem@davemloft.net>
Subject: Re: Translation table available between 'ethtool -k' and 'ethtool
 -K' ? For Linux?
Date: Thu, 20 Nov 2014 23:05:07 -0500 (EST)
Message-ID: <20141120.230507.1288958595564653550.davem@davemloft.net>
References: <BABF60987D48764FA4071AC73CB9C56162EBFBD0AC@AUSX7MCPC101.AMER.DELL.COM>
	<1416526354.7215.4.camel@decadent.org.uk>
	<CA+mtBx9SJ5mhLBMk8E0gGceweMyzJ2icBfjGJc0rjOTDVQZi1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, Spike_White@dell.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaKUEFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 23:05:09 -0500
In-Reply-To: <CA+mtBx9SJ5mhLBMk8E0gGceweMyzJ2icBfjGJc0rjOTDVQZi1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 20 Nov 2014 17:07:44 -0800

> Ben I'm not sure I see this. If we turn off HW offloads and rely on
> the software offloads where is the increased risk? This may result in
> performance degradation for sure, but I really hope at this point that
> the software offload mechanisms in the stack are as least as robust as
> any HW mechanism.

It means you're testing a configuration different from %99 of users
(who are not changing the defaults).  You are by definition testing
code paths with less overall global testing coverage.
