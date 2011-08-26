From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: strange routing issue--packets stop getting forwarded for a live
 connection
Date: Thu, 25 Aug 2011 20:50:03 -0700
Message-ID: <4E5717EB.6030304@fatooh.org>
References: <4E506A46.6060407@fatooh.org> <alpine.LFD.2.00.1108210924010.1581@ja.ssi.bg> <4E50BDFB.7050502@fatooh.org> <alpine.LFD.2.00.1108211142180.1581@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:49690 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab1HZDuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 23:50:06 -0400
In-Reply-To: <alpine.LFD.2.00.1108211142180.1581@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-08-21 02:02, Julian Anastasov wrote:
>>>> 3. MTU size; 1500 on eth0 and 1406 on tun0. Bigger packets have been
>>>> transferred fine.
>>>
>>> 	Lower MTU, it can be PMTUD problem. At 04:50:24.112658
>>> I see 7801:9169 is 1420 bytes and no ICMP FRAG NEEDED is generated.
>>> May be these two regressions explain it:
>>>
>>> http://marc.info/?l=linux-netdev&m=131342172722536&w=2
>>>
>>> 	There are 2 fixes you can try or more recent kernel
>>> tree, for example 3.1-rc2 has the fixes.
>>
>> Many thanks for your reply--it looks like you're on to something. You
>> didn't specify which interface to lower the MTU on, so I tried them each
>> in turn, and found that lowering the MTU on the client machine to 1406
>> (matching tun0 on the router) did indeed solve the problem. That makes
>> sense in retrospect.
> 
> 	I just wanted to note the difference in MTUs
> as a possible cause that triggers the problem. And after
> your confirmation I think the new/patched kernel should work
> without playing with MTUs.

I finally got a chance to test this, and the patched kernel works fine.
Thank you!

-Corey
