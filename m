From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100
 patch)
Date: Thu, 8 Mar 2007 15:13:16 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
 <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
 <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
 <23552.1173395045@death>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-2.smtp.ucla.edu ([169.232.47.136]:46286 "EHLO
	smtp-2.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030843AbXCHXNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 18:13:40 -0500
In-Reply-To: <23552.1173395045@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Mar 2007, Jay Vosburgh wrote:

> 	If you're running active-backup and not using the ARP monitor 
> (arp_interval), then I'm not aware of any possible locking problems in 
> bonding for the kernel version you reference (2.6.20.1).

I'm not using arp_interval.

On Thu, 8 Mar 2007, Jay Vosburgh wrote:
> Chris Stromsoe <cbs@cts.ucla.edu> wrote:
>
>> 1) ip link set mtu 9000 eth2  <-- eth2 is no longer responsive
>>    ip link set mtu 1500 eth2  <-- eth2 remains unresponsive
>>
>> 2) ifup eth2
>>    ifdown eth2
>>
>>    perl -pi -e 's/eth2/eth3/' /etc/network/interfaces
>>
>>    ifup eth3   <--  locks up here
>
> 	This would seem to suggest a problem with skge itself, although 
> there might be some other interaction with bonding that causes the 
> problems for that case.

In both of the above mentioned cases, I was not using bonding.  That was 
with the skge driver only.


-Chris
