From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Sat, 08 Aug 2009 00:17:20 +0200
Message-ID: <4A7CA7F0.60704@inria.fr>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>	<4A7C9A14.7070600@inria.fr>	<20090807175112.a1f57407.billfink@mindspring.com>	<4A7CA24E.4080503@inria.fr> <20090807180840.b27ce794.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:49140
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755419AbZHGWRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 18:17:09 -0400
In-Reply-To: <20090807180840.b27ce794.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> OK.  The tests were run on a 2.6.29.6 kernel so presumably should
> have included the fix you mentioned.
>   

Yes, but I wanted to emphasize that new platforms sometime need some new
code to handle this kind of things. Some Nehalem-specific changes might
be needed now.

>>>> Is the corresponding local_cpus sysfs file wrong as well ?
>>>>         
>>> All sysfs local_cpus values are the same (00000000,000000ff),
>>> so yes they are also wrong.
>>>       
>> And hyperthreading is enabled, right?
>>     
>
> No, hyperthreading is disabled.  It's a dual quad-core system so there
> are a total of 8 cores, 4 on NUMA node 0 and 4 on NUMA node2.
>   

So numa_node says that the device is close to node 0 while local_cpus
says that it's close to all 8 cores ie close to both node0 and node2
(which may well be wrong as well).

Brice

