From: Francesco Fusco <ffusco@redhat.com>
Subject: Re: [PATCH net-next v2 1/2] ipv4: IP_TOS and IP_TTL can be specified
 as ancillary data
Date: Wed, 18 Sep 2013 10:16:00 +0200
Message-ID: <52396140.7010107@redhat.com>
References: <aaa7e0af2fe535ea5216e438b5f65db88dcef8b2.1377257704.git.ffusco@redhat.com> <20130827.145649.1682045616049011855.davem@davemloft.net> <521DAD30.1010903@redhat.com> <20130917.204648.339747836268253489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591Ab3IRIQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 04:16:05 -0400
In-Reply-To: <20130917.204648.339747836268253489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David.
I will resubmit the patches as they are as soon as the merge window 
opens again.

Best,
Francesco

On 09/18/2013 02:46 AM, David Miller wrote:
> From: Francesco Fusco <ffusco@redhat.com>
> Date: Wed, 28 Aug 2013 09:56:32 +0200
>
>> On 08/27/2013 08:56 PM, David Miller wrote:
>>> From: Francesco Fusco <ffusco@redhat.com>
>>> Date: Fri, 23 Aug 2013 14:19:32 +0200
>>>
>>>>     - changed the icmp_cookie ttl field from __s16 to __u8.
>>>>       A value of 0 means that the TTL has not been specified
>>>
>>> Sorry, I have to ask you to change the ttl field type back to __s16
>>> and use "-1" to mean not-specified.
>>>
>>> Zero is a valid TTL setting and it means to not allow the
>>> packet to leave this host.
>>
>> Actually setsockopt() does not allow a TTL value of zero:
>>
>>  From net/ipv4/ip_sockglue.c::do_ip_setsockopt()
>
> Indeed, you are right.
>
> Please resubmit these patches for the next merge window.
>
> Thank you.
>
