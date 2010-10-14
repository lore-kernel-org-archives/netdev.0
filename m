From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: Re: [PATCH] tcp: sack lost marking fixes
Date: Thu, 14 Oct 2010 16:02:02 +0200
Message-ID: <4CB70D5A.7010601@nets.rwth-aachen.de>
References: <alpine.DEB.2.00.1010141429150.26447@wel-95.cs.helsinki.fi> <4CB7077B.2080007@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.nets.RWTH-Aachen.DE ([137.226.12.21]:54053 "EHLO
	MAIL-i4.nets.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753422Ab0JNOCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 10:02:06 -0400
In-Reply-To: <4CB7077B.2080007@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to mention that I will of course have a look at it as soon as =
I
finished the thesis :)

On 14.10.2010 15:36, Lennart Schulte wrote:
> At the moment I don't have any time to spare to look into this since =
my
> master thesis has to be ready in about 2 weeks. Sorry for that!
>=20
> On 14.10.2010 13:42, Ilpo J=E4rvinen wrote:
>> When only fast rexmit should be done, tcp_mark_head_lost marks
>> L too far. Also, sacked_upto below 1 is perfectly valid number,
>> the packets =3D=3D 0 then needs to be trapped elsewhere.
>>
>> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>> ---
>> I think 6830c25b7d08fbbd922959425193791bc42079f2 that added the
>> packets =3D=3D 0 check is mostly wrong but I cc'ed Lennart if he has=
 some=20
>> particular case I'm missing that wouldn't work after this patch.
>>
>> Dave, no particular "bad regression" fixed here, so no absolute need=
 to=20
>> have this in net-2.6 but I leave it up to you whether there or net-n=
ext.
>>
>>  ...
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

