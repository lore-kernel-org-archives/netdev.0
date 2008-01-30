From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 17:23:08 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801301721070.23200@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
 <20080130.055333.192844925.davem@davemloft.net>
 <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
 <20080130082136.1017631d@deepthought> <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
 <20080130143335.7fc9ea21@deepthought>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:60724 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbYA3XXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 18:23:14 -0500
In-Reply-To: <20080130143335.7fc9ea21@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

>>>> Indeed, we are not asking to see 1000 Mb/s.  We'd be happy to see 900
>>>> Mb/s.
>>>>
>>>> Netperf is trasmitting a large buffer in MTU-sized packets (min 1500
>>>> bytes).  Since the acks are only about 60 bytes in size, they should be
>>>> around 4% of the total traffic.  Hence we would not expect to see more
>>>> than 960 Mb/s.
>>
>>> Don't forget the network overhead: http://sd.wareonearth.com/~phil/net/overhead/
>>> Max TCP Payload data rates over ethernet:
>>>  (1500-40)/(38+1500) = 94.9285 %  IPv4, minimal headers
>>>  (1500-52)/(38+1500) = 94.1482 %  IPv4, TCP timestamps
>>
>> Yes.  If you look further down the page, you will see that with jumbo
>> frames (which we have also tried) on Gb/s ethernet the maximum throughput
>> is:
>>
>>    (9000-20-20-12)/(9000+14+4+7+1+12)*1000000000/1000000 = 990.042 Mbps
>>
>> We are very far from this number -- averaging perhaps 600 or 700 Mbps.

> That is the upper bound of performance on a standard PCI bus (32 bit).
> To go higher you need PCI-X or PCI-Express. Also make sure you are really
> getting 64-bit PCI, because I have seen some e1000 PCI-X boards that
> are only 32bit.

The motherboard NIC is in a PCI-e x1 slot.  This has a maximum speed of 
250 MB/s (2 Gb/s) in each direction.  It should be a factor of 2 more 
interface speed than is needed.

Cheers,
 	Bruce
