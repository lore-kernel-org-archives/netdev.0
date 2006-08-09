From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 9 Aug 2006 11:48:18 +0200
Message-ID: <20060809094818.GW14627@postel.suug.ch>
References: <20060808221651.GS14627@postel.suug.ch> <20060808.164345.91207648.davem@davemloft.net> <44D98133.8040707@tcs.hut.fi> <20060808.233442.41636358.davem@davemloft.net> <44D99E73.1060305@tcs.hut.fi> <20060809092311.GU14627@postel.suug.ch> <44D9ADFB.90200@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:58515 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030618AbWHIJr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 05:47:58 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <44D9ADFB.90200@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-08-09 12:42
> Ok, it might require quite big changes to the existing code, but if
> someone is willing to take a look at it I wouldn't be against it :-)

I'll provide a patch soon.

> You know, I'm starting to think we could perhaps get rid of
> ip6_null_entry altogether. I at least don't really see any good reason
> to keep it after such changes.
> 
> This would apply even more strongly to the new ip6_prohibit_entry and
> ip6_blk_hole_entry as they don't even serve as routing table dummy entries.

Absolutely, that's the whole point from my perspective, they're
only holding an error code and somewhat hiding error handling.
