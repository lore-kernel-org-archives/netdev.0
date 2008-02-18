From: Martin Devera <devik@cdi.cz>
Subject: Re: [PATCH 2.6.24 1/1] sch_htb: fix "too many events" situation
Date: Mon, 18 Feb 2008 09:03:52 +0100
Message-ID: <47B93BE8.7010905@cdi.cz>
References: <E1JPn6W-0002J2-5x@luxik.cdi.cz> <20080217.232829.222344360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:43272 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbYBRID5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 03:03:57 -0500
In-Reply-To: <20080217.232829.222344360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> up to single jiffy interval and then delay remainder to other
>> jiffy.
>>
>> Signed-off-by: Martin Devera <devik@cdi.cz>
> 
> I think we would be wise to use something other than loops_per_jiffy.
> 
> Depending upon the loop calibration method used by a particular
> architecture it can me one of many different things.
> 
> Some platforms don't even make use of it and thus leave it at it's

aha, ok, I'm not so informed about crossplatform issues.
I was also thining about looking at jiffies value and stop once
it is startjiffy+2, but with NO_HZ introduction, are jiffies
still incremented ?
