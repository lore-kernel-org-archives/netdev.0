From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Tue, 19 Aug 2008 14:28:16 +0800
Message-ID: <48AA6800.1020506@cn.fujitsu.com>
References: <48A911AD.7060102@cn.fujitsu.com>	<48A9799B.4040409@hp.com> <20080818.223857.125980599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61530 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYHSG2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 02:28:54 -0400
In-Reply-To: <20080818.223857.125980599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 18 Aug 2008 09:31:07 -0400
> 
>> I don't think that's correct at all.  The code path shows here is
>> when there are no received options and no sticky options set.  In
>> such case, we shouldn't be returning multicast or bound interfaces.
>> We should be returning 0.

I use setsockopt() to set the bounded interface of the socket, and 
then I get receiving interface index while no message is received through
the above socket,shoudn't the bounded interface be returned?

>>
>> Additionally the address returned is completely bogus as well. We
>> are returning the address our peer instead of the one of our own
>> addresses.

If message is received,the address returned is what the received
message refered to, otherwise the address returned is what I used setsockopt()
to set before.

> 
> Yang, please fix this up, thank you.
> 
> 

Seems that I misunderstood the RFC?
