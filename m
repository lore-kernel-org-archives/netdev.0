From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: sparse noise due to patch "net: fix kmemcheck annotations"
Date: Wed, 11 Nov 2009 22:42:40 +0100
Message-ID: <4AFB2FD0.4070805@s5r6.in-berlin.de>
References: <4AFB217E.2040209@s5r6.in-berlin.de> <4AFB28DE.8070000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:34070 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759320AbZKKVmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:42:52 -0500
In-Reply-To: <4AFB28DE.8070000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Stefan Richter a =E9crit :
>> include/linux/skbuff.h:357:41: error: invalid bitfield specifier for
>> type restricted __be16.
=2E..
> No problem here... how do you get this error, and what is your sparse=
 version ?

It's sparse 0.4.2.
The note is only logged with 'make ... CF=3D"-D__CHECK_ENDIAN__"'.

I guess sparse could be taught to ignore :_ suffixes if the suffix
covers the whole width of the type...  unless there is something that
could be improved in kmemcheck.
--=20
Stefan Richter
-=3D=3D=3D=3D=3D-=3D=3D--=3D =3D-=3D=3D -=3D-=3D=3D
http://arcgraph.de/sr/
