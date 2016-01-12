From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 16:52:39 +0100
Message-ID: <56952147.80201@stressinduktion.org>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:52181 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753323AbcALPwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 10:52:41 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id B111B20770
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 10:52:40 -0500 (EST)
In-Reply-To: <56951D1D.5080602@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2016 16:34, Hannes Frederic Sowa wrote:
> On 29.12.2015 11:54, Stas Sergeev wrote:
>> Hello.
>>
>> I was hitting a strange problem when some internet hosts
>> suddenly stops responding until I reboot. ping to these
>> host gives "Destination Host Unreachable". After the
>> initial confusion, I've finally got to
>> ip route get
>> and got something quite strange.
>>
>>
>> Example for GOOD address (the one that I can ping):
>>
>> ip route get 91.189.89.237
>> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>>      cache
>>
>>
>> Example for BAD address (the one that stopped responding):
>>
>> ip route get 91.189.89.238
>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>      cache <redirected>
>
> I tried to understand this thread and now wonder why this redirect route
> isn't there always. Can you please summarize again why this shouldn't
> happen? It looks totally fine to me from the configuration of your
> router and the subnet masks.

Just an addendum:

In IPv6 a redirect is seen as a notification telling hosts, this new 
address is on the same link as you. I think this semantic is the same 
for IPv4, so we are informing you that in essence you are getting a /32 
route installed to your new interface and can do link layer resolving of 
the new host.

I do think this is valid and fine.

Bye,
Hannes
