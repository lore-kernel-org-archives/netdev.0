From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Thu, 01 Dec 2011 10:25:28 -0800
Message-ID: <4ED7C698.40003@hp.com>
References: <20111201082436.20f21e52@nehalam.linuxnetplumber.net> <AE90C24D6B3A694183C094C60CF0A2F6D8AEFA@saturn3.aculab.com> <20111201085701.02f885c5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:17922 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016Ab1LASZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 13:25:31 -0500
In-Reply-To: <20111201085701.02f885c5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2011 08:57 AM, Stephen Hemminger wrote:
> On Thu, 1 Dec 2011 16:38:51 -0000
> "David Laight"<David.Laight@ACULAB.COM>  wrote:
>
>>
>>> One idea to do small delays at higher speed is to insert
>>> dummy pad frames into the device.
>>> It would mean generating garbage, but would allow for
>>> highly accurate fine grain delay.
>>
>> Not a good idea.
>> They would have to be sent to a known MAC address
>> otherwise all the ethernet switches would forward them
>> on all output ports.
>>
>> 	David
>>
>>
>
> Yes it would have to be a constant destination, not sure if there
> is a discard value in Ethernet protocol spec.

Aren't there special addresses that aren't supposed to be forwarded by 
(intelligent) switches?  IIRC LLDP uses such things.  Though the IEEE 
may take a dim view of using it for such a purpose, and knuth only knows 
what switch bugs would be uncovered that way...

http://standards.ieee.org/develop/regauth/grpmac/public.html
http://en.wikipedia.org/wiki/Link_Layer_Discovery_Protocol

rick jones
