From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 15:58:55 +0100
Message-ID: <49C10C2F.1030501@trash.net>
References: <20090318112937.675BF13A4B0@koiott.tartu-labor> <Pine.LNX.4.64.0903181332140.13734@ondatra.tartu-labor> <49C107AB.1030003@trash.net> <200903181652.27928.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43495 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbZCRO66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 10:58:58 -0400
In-Reply-To: <200903181652.27928.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:
> On Wednesday 18 March 2009 16:39:39 Patrick McHardy wrote:
>> On top it has far smaller code and less memory usage as soon as
>> you have more than one CPU, its lockless, no default counters,
>> no overhead for unused chains, etc etc.
>>
>> When the time has come, I will of course post benchmarks.
>>
> Thanks a lot for your code Patrick.
> I will try as soon as i can.
> 
> I dont think hash and rbtrees is suboptimal.
> I have really a lot of situations where i need large set of ip's or ports to 
> be added in similar rule, which is forced to be linear. And if i even build 
> tree manually - it will be really headache to add new hosts.
> 
> nftables looks very promissing in this case

Yes, but we can easily decrease the overhead per data item using
something different. A bigger fanout factor would additionally
decrease lookup times.
