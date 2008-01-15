From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Re: [PATCH 2/4] [ROSE] rose_get_route() template
Date: Tue, 15 Jan 2008 15:42:35 +0100
Message-ID: <478CC65B.9000505@ccr.jussieu.fr>
References: <47630274.1080706@ccr.jussieu.fr> <47892051.8000404@ccr.jussieu.fr> <478923FD.9040704@cosmosbay.com> <47893127.2080606@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:47538 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbYAOOnF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 09:43:05 -0500
In-Reply-To: <47893127.2080606@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wrote a "simplified" get_route() function.
It is declared as static following judicious Eric's remark.

Then, the following patch of include/net/rose.h is no more
necessary.

A new commit for rose_get_route() will be presented in next
message.

Thank you Eric for pushing me to reexamine my code.

Regards,

Bernard P.



Bernard Pidoux wrote:
>=20
>=20
> Eric Dumazet wrote:
>> Bernard Pidoux a =E9crit :
>>>  From 46bccce1e660a39bcc8f8cf87d4c17de33f4ba48 Mon Sep 17 00:00:00 =
2001
>>> From: Bernard Pidoux <f6bvp@amsat.org>
>>> Date: Thu, 10 Jan 2008 23:01:46 +0100
>>> Subject: [PATCH 2/4] [ROSE] template declaration for rose_get_route=
()
>>>
>>> Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
>>> ---
>>>  include/net/rose.h |    1 +
>>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/net/rose.h b/include/net/rose.h
>>> index e5bb084..d3ab453 100644
>>> --- a/include/net/rose.h
>>> +++ b/include/net/rose.h
>>> @@ -202,6 +202,7 @@ extern struct net_device *rose_dev_first(void);
>>>  extern struct net_device *rose_dev_get(rose_address *);
>>>  extern struct rose_route *rose_route_free_lci(unsigned int, struct=
=20
>>> rose_neigh *);
>>>  extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned=20
>>> char *, unsigned char *);
>>> +extern struct rose_neigh *rose_get_route(rose_address *, unsigned=20
>>> char *, unsigned char *);
>>>  extern int  rose_rt_ioctl(unsigned int, void __user *);
>>>  extern void rose_link_failed(ax25_cb *, int);
>>>  extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
>>> --=20
>>
>> Strange... if rose_get_route() is used only in net/rose/rose_route.c=
,=20
>> why dont you define it static, and not extern in include/net/rose.h =
?
>>
>>
>>
>=20
> I agree. You are perfectly right.
> There is no need to declare rose_get_route() external.
> I stupidly copied rose_get_neigh()definition from which I derived=20
> rose_get_route();
>=20
> Also I am not sure that setting cause and diagnostic is necessary, as=
=20
> they are not used by the calling function.
>=20
> By the way. I made a typo in [PATCH 4/4].
>=20
> Instead of "Initial connection to rose neighbour nodes was unusually,
> t0 timer was blocked and application program could not
> use socket."
>=20
> One should read
> "Initial connection to rose neighbour nodes was unusually,
> long, t0 timer was blocked and application program could not
> use socket."
>=20
> Bernard P.
>=20
>=20
>=20

