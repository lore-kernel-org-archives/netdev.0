From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Question about netns & AF_UNIX
Date: Thu, 27 May 2010 22:16:28 +0200
Message-ID: <4BFED31C.2070702@free.fr>
References: <AANLkTikBuXfzS-UIL7bDMvfpL5lx9gMqHTpGg-jrm5Zv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:45555 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab0E0UQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 16:16:40 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4RKGcQD002369
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 20:16:38 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4RKGcZo1220666
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 21:16:38 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4RKGcwY029847
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 21:16:38 +0100
In-Reply-To: <AANLkTikBuXfzS-UIL7bDMvfpL5lx9gMqHTpGg-jrm5Zv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2010 04:38 PM, Mart=EDn Ferrari wrote:
> Hi, again a question about netns...
>
> I seem to recall being able to use AF_UNIX sockets across network nam=
e
> spaces, but I cannot reproduce that with a current kernel. Probably m=
y
> test was fubar (I've lost the script).
>   =20

No, that was never the case. Maybe you tested with a patched kernel=20
allowing to cross-namespace connect.
> In any case: is a design decision to forbid this, even when the file
> system is shared? I found some discussions from 2008, but I don't see
> an agreement being reached...
>   =20

There was a discussion about that but with a simple hack removing the=20
test against the namespace when connecting.
The problem is nobody investigated that against credentials in ancillar=
y=20
messages, or other particularity of the af_unix socket vs the namespace=
s.

> I also wonder if filedescriptor passing thru ancilliary messages will
> work (that is, with unix sockets that I've created before the netns
> change).
>   =20

Yes.

Thanks
   -- Daniel
