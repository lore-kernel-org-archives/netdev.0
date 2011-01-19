From: Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: [PATCH] net: fix can_checksum_protocol() arguments swap
Date: Wed, 19 Jan 2011 16:01:15 +0100
Message-ID: <4D36FCBB.2060309@xmsnet.nl>
References: <1295434296.3273.18.camel@edumazet-laptop> <AANLkTi=sJGFPNkzG9sDDjiREsRXVj8U_rWNr6sWvhX-e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail10.mail.sp.isp-net.nl ([217.149.192.62]:57720 "EHLO
	webmail10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754563Ab1ASPAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 10:00:22 -0500
In-Reply-To: <AANLkTi=sJGFPNkzG9sDDjiREsRXVj8U_rWNr6sWvhX-e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2011 02:33 PM, Jesse Gross wrote:
> On Wed, Jan 19, 2011 at 2:51 AM, Eric Dumazet<eric.dumazet@gmail.com>  wrote:
>> commit 0363466866d901fbc (net offloading: Convert checksums to use
>> centrally computed features.) mistakenly swapped can_checksum_protocol()
>> arguments.
>>
>> This broke IPv6 on bnx2 for instance, on NIC without TCPv6 checksum
>> offloads.
>>
>> Reported-by: Hans de Bruin<jmdebruin@xmsnet.nl>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> CC: Jesse Gross<jesse@nicira.com>
>> ---
>> I cant believe I spent so much time on this bug.
>
> Thanks Eric, I was staring at this code and I can't believe that I
> didn't see it.
>
> Acked-by: Jesse Gross<jesse@nicira.com>

I have applied the patch and the ipv6 connectivity is back.

-- 
Hans
