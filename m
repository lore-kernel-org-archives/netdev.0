From: f6bvp <f6bvp@free.fr>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel panic
Date: Sat, 5 Mar 2016 18:32:04 +0100
Message-ID: <56DB1814.2050902@free.fr>
References: <56D5FD7A.5080104@free.fr>
 <20160303.170253.1102862150292919836.davem@davemloft.net>
 <56DAFC1A.5000408@free.fr>
 <20160305.112226.2192524821017178121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva144.upmc.fr ([134.157.0.144]:64043 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750744AbcCERdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2016 12:33:11 -0500
In-Reply-To: <20160305.112226.2192524821017178121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Le 05/03/2016 17:22, David Miller a =E9crit :
> From: f6bvp <f6bvp@free.fr>
> Date: Sat, 5 Mar 2016 16:32:42 +0100
>=20
>> I understand I did not explain clearly or completely things.
>>
>> I agree that each time patched rose_xmit() is calling
>> rose_route_frame() it will
>> get a 0 return.
>> And I think this is what was intended by the author of rose_xmit().
>=20
> If that's what he intended he would have implemented the entirety of
> rose_xmit() as "kfree_skb(skb)".  But that's obviously not the case.
>=20
> The author meant the packet to be sent in some way, perhaps using a
> default path or something like that.

Via a NULL pointer ?
I don't see how it could work.

>=20
> So please stop telling me over and over again that this function
> is meant to simply drop all packets, it's not true.
>=20
I am just making hypothesis and trying to infer some deductions from th=
e
behaviour of program when there is no more kernel panic.

If there is a situation leading to a kernel panic, I thought code shoul=
d
be changed ?
What is the problem replacing a NULL argument by an array of 0 ?
