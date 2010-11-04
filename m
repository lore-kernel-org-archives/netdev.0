From: David Miller <davem@davemloft.net>
Subject: Re: Freeing alive fib_info caused by ebc0ffae5
Date: Thu, 04 Nov 2010 12:06:19 -0700 (PDT)
Message-ID: <20101104.120619.226790915.davem@davemloft.net>
References: <1288866626.2659.71.camel@edumazet-laptop>
	<1288869699.2659.77.camel@edumazet-laptop>
	<1288870526.30549.19.camel@concordia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43505
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475Ab0KDTFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 15:05:55 -0400
In-Reply-To: <1288870526.30549.19.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Ellerman <michael@ellerman.id.au>
Date: Thu, 04 Nov 2010 22:35:26 +1100

> On Thu, 2010-11-04 at 12:21 +0100, Eric Dumazet wrote:
>> [PATCH] fib: fib_result_assign() should not change fib refcounts
>> 
>> After commit ebc0ffae5 (RCU conversion of fib_lookup()),
>> fib_result_assign()  should not change fib refcounts anymore.
>> 
>> Thanks to Michael who did the bisection and bug report.
 ...
> Perfect, that fixes it, thanks!

Applied, thanks everyone!
