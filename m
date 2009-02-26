From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 14:43:02 +0100
Message-ID: <49A69C66.6000005@free.fr>
References: <49A69784.6070204@free.fr> <20090226.052411.77955912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:49499 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbZBZNng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:43:36 -0500
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id n1QDhYw9025668
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 13:43:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1QDhY812965642
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 13:43:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1QDhYTW017039
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 13:43:34 GMT
In-Reply-To: <20090226.052411.77955912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <daniel.lezcano@free.fr>
> Date: Thu, 26 Feb 2009 14:22:12 +0100
>
>   
>> I saw in net/ipv6/Kconfig a comment saying
>> "IPv6 as module will cause a CRASH if you try to unload it".
>>
>> If I refer to this comment, that means unloading of ipv6 is not
>> supported (which makes sense), will it be one day supported?
>>     
>
> It's very unlikely to be supported any time soon.
>
> Maybe "one day" as in 5 years from now at the earliest.
>
> It's just such an enormous set of problems to solve to make it work,
> and there are so many more urgent issues to work on.
>   
I was wondering if it would have make sense to remove the unloading 
module code from ipv6 which is big at all and not testable.

