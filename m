From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 18:26:24 +0100
Message-ID: <56953740.1090204@stressinduktion.org>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
 <56953059.1020506@list.ru> <569532A6.1070905@stressinduktion.org>
 <56953560.9050906@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:45526 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763513AbcALR00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 12:26:26 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 21E5E20A68
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 12:26:26 -0500 (EST)
In-Reply-To: <56953560.9050906@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2016 18:18, Stas Sergeev wrote:
> 12.01.2016 20:06, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> On 12.01.2016 17:56, Stas Sergeev wrote:
>>> 12.01.2016 19:42, Stas Sergeev =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Also the rfc1620 you pointed, seems to be saying this:
>>>
>>>                   A Redirect message SHOULD be silently discarded i=
f the
>>>                   new router address it specifies is not on the sam=
e
>>>                   connected (sub-) net through which the Redirect a=
rrived,
>>>                   or if the source of the Redirect is not the curre=
nt
>>>                   first-hop router for the specified destination.
>>>
>>> It seems, this is exactly the rule we were trying to find
>>> during the thread. And it seems violated, either. Unless I am
>>> mis-interpreting it, of course.
>>
>> If you read on you will read that with shared_media this exact claus=
e (the first of those) is not in effect any more.
> OK. But how to get such a redirect to work, if (checked with
> tcpdump) the packets do not even go to eth0, but to "lo"?

I don't know, the router must be on the same shared medium. I guess=20
physical reconfiguration is required?

Aren't there arp request for the host on eth0?

> And how to deal with the above quote from rfc1812?
>
>> I don't know why shared_media=3D1 is the default in Linux, this deci=
sion was made long before I joined here. Anyway, with shared_media=3D1 =
this is absolutely the required behavior.
> Then it should work. How? :)

What should work? Sorry, I can't follow you. Everything looks fine to=20
me. The default is shared_media, so servers send such redirects and=20
client accept those. If it would be 0 the rfc1812 applies and should=20
stop servers to send such redirects and clients to accept those.

Bye,
Hannes
