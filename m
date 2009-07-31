From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: neigh_periodic_timer expires too often
Date: Fri, 31 Jul 2009 15:22:28 +0300
Message-ID: <4A72E204.3050704@nokia.com>
References: <4A717985.7060909@nokia.com> <4A719CDB.3060004@gmail.com> <4A71AF1D.9020000@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kristo Tero (Nokia-D/Tampere)" <Tero.Kristo@nokia.com>
To: ext Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:59820 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbZGaMWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 08:22:31 -0400
In-Reply-To: <4A71AF1D.9020000@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coelho Luciano (Nokia-D/Helsinki) wrote:
> ext Eric Dumazet wrote:
>   
>> So please test it and tell me/us you like it :)
>>   
>>     
>
> I applied your patch on top of the 2.6.28 I'm using and will start 
> testing it now.  I can also try to test it on top of 2.6.31-rc4 plus 
> wireless-testing stuff, if needed.
>
> I'll tell you that I liked your patch in a moment (I actually already 
> liked it, but I'll wait until I know it works before I tell you ;)
>   

Just a small update.  We have run some very basic tests with 2.6.28.  
The patch seems to work fine and we don't see excessive wake-ups from 
neigh anymore (thanks Tero for helping with the tests).  We will still 
run one of our full release test rounds in order to make sure that there 
are no regressions.  I'll let you know when we have some more results.

-- 
Cheers,
Luca.

