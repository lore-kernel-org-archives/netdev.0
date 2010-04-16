From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network multiqueue question
Date: Fri, 16 Apr 2010 06:53:53 +0200
Message-ID: <1271393633.16881.3606.camel@edumazet-laptop>
References: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
	 <1271353637.16881.2846.camel@edumazet-laptop>
	 <j2gb65cae941004152100je5a3c3c9lba9e96ecb95bf04c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: "George B." <georgeb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55305 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab0DPEyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 00:54:04 -0400
Received: by bwz25 with SMTP id 25so2523943bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 21:54:00 -0700 (PDT)
In-Reply-To: <j2gb65cae941004152100je5a3c3c9lba9e96ecb95bf04c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 21:00 -0700, George B. a =C3=A9crit :
> On Thu, Apr 15, 2010 at 10:47 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>=20
>=20
>=20
> > Since this bothers me a bit, I will probably work on this in a near
> > future. (adding real multiqueue capability and RCU to bonding fast
> > paths)
> >
> > Ref: http://permalink.gmane.org/gmane.linux.network/152987
>=20
> That would be great and you would have my sincere thanks..  And if
> anyone is interested, what we do is take a pair of "top of rack"
> switches and cluster them together so they appear as one switch.
> Configure a LAG consisting of a port on each physical switch to a pai=
r
> of bonded interfaces on the server and use mode 2 bonding.  In normal
> operation, both interfaces are active.  Should one switch experience =
a
> power or interface failure, the server sees one of the interfaces fai=
l
> but just keeps working on the remaining interface.  There is no
> "failover" event going on.
>=20

What kind of traffic do your machines manage exactly ?

On server, you use two ports of the same kind (same number of queues) ?


