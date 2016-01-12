From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 19:03:12 +0300
Message-ID: <569523C0.5040504@list.ru>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.mail.ru ([94.100.181.178]:40998 "EHLO smtp23.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbcALQDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 11:03:18 -0500
In-Reply-To: <56952147.80201@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

12.01.2016 18:52, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 12.01.2016 16:34, Hannes Frederic Sowa wrote:
>> On 29.12.2015 11:54, Stas Sergeev wrote:
>>> Hello.
>>>
>>> I was hitting a strange problem when some internet hosts
>>> suddenly stops responding until I reboot. ping to these
>>> host gives "Destination Host Unreachable". After the
>>> initial confusion, I've finally got to
>>> ip route get
>>> and got something quite strange.
>>>
>>>
>>> Example for GOOD address (the one that I can ping):
>>>
>>> ip route get 91.189.89.237
>>> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>>>      cache
>>>
>>>
>>> Example for BAD address (the one that stopped responding):
>>>
>>> ip route get 91.189.89.238
>>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>>      cache <redirected>
>>
>> I tried to understand this thread and now wonder why this redirect r=
oute
>> isn't there always. Can you please summarize again why this shouldn'=
t
>> happen? It looks totally fine to me from the configuration of your
>> router and the subnet masks.
>=20
> Just an addendum:
>=20
> In IPv6 a redirect is seen as a notification telling hosts, this new =
address is on the same link as you. I think this semantic is the same f=
or IPv4, so we are informing you that in essence you are
> getting a /32 route installed to your new interface and can do link l=
ayer resolving of the new host.
>=20
> I do think this is valid and fine.
You can't call "valid and fine" something that doesn't
work, at first place. Why and where does it fail, was the
subject of this thread.
If you think router did the right thing, then please explain
the breakage from that point of view.
