From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 07 Aug 2009 23:53:18 +0200
Message-ID: <4A7CA24E.4080503@inria.fr>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>	<4A7C9A14.7070600@inria.fr> <20090807175112.a1f57407.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:12229
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932065AbZHGVxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 17:53:07 -0400
In-Reply-To: <20090807175112.a1f57407.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
>> I've seen some cases in the past where numa_node was always 0 on
>> quad-Opteron machines with a PCI bus on node 1. IIRC it got fixed in
>> later kernels thanks to patches from Yinghai Lu (CC'ed).
>>     
>
> By later kernels do you mean 2.6.30 or 2.6.31?
>   

No, I meant "later than when the problem occured". I was using 2.6.22 at
this point and the problem was fixed somewhere around 2.6.25.

>> Is the corresponding local_cpus sysfs file wrong as well ?
>>     
>
> All sysfs local_cpus values are the same (00000000,000000ff),
> so yes they are also wrong.
>   

And hyperthreading is enabled, right?

Brice

