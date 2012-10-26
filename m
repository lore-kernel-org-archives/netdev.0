From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next v2 2/5] rtnl/ipv6: use netconf msg to
 advertise forwarding status
Date: Fri, 26 Oct 2012 05:17:19 -0400 (EDT)
Message-ID: <20121026.051719.783711995394609246.davem@davemloft.net>
References: <1351094579-3911-3-git-send-email-nicolas.dichtel@6wind.com>
	<20121026.021830.1470799532580844849.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7070@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857Ab2JZJRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 05:17:21 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7070@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 26 Oct 2012 10:03:54 +0100

>> > +static inline int inet6_netconf_msgsize_devconf(int type)
>> 
>> Outside of header files, we don't add explicit inlines, we let
>> the compiler decide.
> 
> Hmmm.... In my experience it makes bad decisions,
> even for static functions that are only called once.
> And yes, I have checked that the inlined code is smaller
> and faster.

This isn't for you to decide.  It's been decided long ago that we're
doing things tree wide doing things this way.

If GCC is not perfect, submit a well formed bug report, don't complain
here.
