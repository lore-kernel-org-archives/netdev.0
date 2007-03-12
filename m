From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100
 patch)
Date: Mon, 12 Mar 2007 15:09:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
 <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
 <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
 <23552.1173395045@death> <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-3.smtp.ucla.edu ([169.232.48.136]:39325 "EHLO
	smtp-3.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932774AbXCLWaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 18:30:39 -0400
In-Reply-To: <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Mar 2007, Chris Stromsoe wrote:
> On Thu, 8 Mar 2007, Jay Vosburgh wrote:
>> Chris Stromsoe <cbs@cts.ucla.edu> wrote:
>> 
>>> 1) ip link set mtu 9000 eth2  <-- eth2 is no longer responsive
>>>    ip link set mtu 1500 eth2  <-- eth2 remains unresponsive
>>> 
>>> 2) ifup eth2
>>>    ifdown eth2
>>>
>>>    perl -pi -e 's/eth2/eth3/' /etc/network/interfaces
>>>
>>>    ifup eth3   <--  locks up here
>>
>> 	This would seem to suggest a problem with skge itself, although 
>> there might be some other interaction with bonding that causes the 
>> problems for that case.
>
> In both of the above mentioned cases, I was not using bonding.  That was 
> with the skge driver only.

The above tests both work fine with the 2.6.20.1 sk98lin driver loaded as 
"modprobe sk98lin RlmtMode=DualNet".

I can change the MTU, add and remove eth2/eth3 from the bond, and up and 
down the interface.  It also works fine with different hardware (e100, 
e1000, tg3, bnx2).  Running both interfaces alone without the bonding 
driver also works (I can up and down the interfaces with no side-affects).




-Chris
