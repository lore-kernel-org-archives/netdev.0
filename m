From: Naveen BN <naveen.bn@globaledgesoft.com>
Subject: Re: xfrm command fails
Date: Wed, 11 Nov 2009 12:40:39 +0530
Message-ID: <4AFA636F.4010200@globaledgesoft.com>
References: <4AFA4B60.3090306@globaledgesoft.com> <4AFA5499.2090605@globaledgesoft.com> <4AFA56B1.1010109@globaledgesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gesmail.globaledgesoft.com ([203.76.137.4]:37570 "EHLO
	gesmail.globaledgesoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751316AbZKKHar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 02:30:47 -0500
In-Reply-To: <4AFA56B1.1010109@globaledgesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
This proper command to create SA using ip xfrm is
ip xfrm state add src 192.168.1.20 dst 192.168.1.5 proto esp spi 
0x354cb04b mode tunnel reqid 16385 replay-window 32 auth sha1 
0xecf02a5cf6568556e1bdcd961c7ec3f92afd01cc enc aes 
0x5c0cfa9672ce67ba545b593076dfb278 sel src 0.0.0.0/0 dst 0.0.0.0/0

But how can create a session based SA with ports also used in sa 
selection for the same host .
Please help me on this . In selection of OUTBOUND SA does ports also 
involve.

Regards
Naveen

Naveen BN wrote:
> adding David in loop
> Naveen BN wrote:
>> I am using fedora with version => 2.6.23.1-42.fc8.
>> Please guide me to solve the error message "RTNETLINK answers: 
>> Function not implemented"
>>
>> Regards
>> Naveen
>> Naveen BN wrote:
>>> Hi All
>>> I am trying to create a security association using ip xfrm command, 
>>> but i get an message saying
>>> "*RTNETLINK answers: Function not implemented*" and ip xfrm state 
>>> succeeds in displaying  sa  written using setkey .
>>>
>>> ip xfrm state add src 192.168.1.20 dst 192.168.1.5 proto esp spi 
>>> 0x354cb04b mode tunnel reqid 16385 replay-window 32 auth hmac 
>>> 0xecf02a5cf6568556e1bdcd961c7ec3f92afd01cc enc cbc 
>>> 0x5c0cfa9672ce67ba545b593076dfb278 sel src 0.0.0.0/0 dst 0.0.0.0/0
>>>
>>> ERROR message => "RTNETLINK answers: Function not implemented"
>>>
>>> Regards
>>> Naveen
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

