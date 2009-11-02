From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 11:17:07 -0500
Message-ID: <4AEF0603.7060502@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com> <4AEDDF33.9030205@gmail.com> <4AEECFA8.1080306@gmail.com> <alpine.DEB.2.00.0911021448280.19761@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:56140 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542AbZKBQRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 11:17:09 -0500
Received: by ewy28 with SMTP id 28so4992843ewy.18
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 08:17:13 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.0911021448280.19761@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> Are you talking about particular case?!? ...You can safely split into=
 even=20
> more parts if there are cleanups which is essential. ...We'll not sto=
p you=20
> from doing that nor be angry if do that.
>=20
Actually, my earliest posting split the original single patch, and Mill=
er
*did* seem angry.  I had to put it back together again -- and then he
only commented on one thing that *was* in my first post, causing me to
have to redo the entire thing a third time.  So, I've been posting patc=
hes
in bigger groups than I originally write and test.


> That kind of response certainly won't help you any. ...First, you sai=
d you=20
> adapt the current style but for some reason immediately start to say =
why=20
> you would careless about that principle. ...Also, telling that you ha=
ve=20
> lots of experience here and there will not get you there either ;-).
>=20
I meant I adapt to existing style (no matter how odd) in places where I=
'm
patching, so that *patches* are easier to review -- and write in a more
elegant style where I'm making a significant stand-alone addition.

I'd thought that constant-left style was pretty common around here, as =
grep
tells me there are hundreds upon hundreds of examples in arch, drivers,=
 net,
and sound....

Seems like I'm not alone.


Eric Dumazet wrote:
# Cooking patches to linux is not only matter of good ideas and program=
ming (and Dropping
# patches for the masses).
#
# Its also a matter of convincing _people_ that your additions will be =
maintainable
# when you leave kernel programming and let people like us correct bugs=
=2E
#
# For the moment, I am not convinced at all. I prefer to talk now.
#
OK, I'm talking.  Thank you.

Linux already has a fair amount of my code in it, often hard to recogni=
ze
now after 15 years, so I'm pretty sure that my code has been found
maintainable in the past.

Anyway, I don't want to argue about it on an open mailing list.  I'm mo=
re
interested in getting work done!


# Note: I did read your TCPCT 25 pages documentation and very am intere=
sted by this
# improvement, but its _also_ important to implement it in the normal w=
ay.
# (I wish this document could be public in a RFC form)
#
It will be, when we have running code, as I'm loath to publish until I'=
m
certain it *can* be implemented.

I've something like 40 RFCs published over the years.
