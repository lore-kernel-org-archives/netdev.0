From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 07 Feb 2012 13:36:17 -0500 (EST)
Message-ID: <20120207.133617.2073149861534644798.davem@davemloft.net>
References: <4F31292F.2090503@parallels.com>
	<20120207.122931.1509587729423704935.davem@davemloft.net>
	<20120207183911.4dd65ac8@destiny.ordissimo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: anisse@astier.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755808Ab2BGSgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:36:22 -0500
In-Reply-To: <20120207183911.4dd65ac8@destiny.ordissimo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anisse Astier <anisse@astier.eu>
Date: Tue, 7 Feb 2012 18:39:11 +0100

> On Tue, 07 Feb 2012 12:29:31 -0500 (EST), David Miller <davem@davemloft.net> wrote :
> 
>> From: Pavel Emelyanov <xemul@parallels.com>
>> Date: Tue, 07 Feb 2012 17:37:51 +0400
>> 
>> > @@ -409,7 +409,7 @@ config INET_TCP_DIAG
>> >  
>> >  config INET_UDP_DIAG
>> >  	tristate "UDP: socket monitoring interface"
>> > -	depends on INET_DIAG
>> > +	depends on INET_DIAG && IPV6
>> 
>> This needs to be something like "INET_DIAG && (IPV6 || IPV6=n)"
> 
> Yes, this works better. This is the right solution.
> 
> Tested-by: Anisse Astier <anisse@astier.eu>

The patch was corrupted by your email client, it turned all the
tab characters into spaces, you also didn't write an appropriate
commit message.

I took care of this, but if you plan to submit any patch at all in
the future, even as an "request for comments" and testing, you must
keep these issues in mind.
