From: David Miller <davem@davemloft.net>
Subject: Re: Problems with /proc/net/tcp6 - possible bug - ipv6
Date: Mon, 24 Jan 2011 14:31:41 -0800 (PST)
Message-ID: <20110124.143141.104045281.davem@davemloft.net>
References: <115440.16148.qm@web63902.mail.re1.yahoo.com>
	<1295731235.2651.66.camel@edumazet-laptop>
	<1295732444.2651.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: runningdoglackey@yahoo.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295732444.2651.68.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Jan 2011 22:40:44 +0100

> Le samedi 22 janvier 2011 =E0 22:20 +0100, Eric Dumazet a =E9crit :
>> Le samedi 22 janvier 2011 =E0 11:42 -0800, PK a =E9crit :
>> > Eric Dumazet wrote:
>> > >=20
>> > > I had some incidents, after hours of testing...
>> > >
>> > > After following patch, I could not reproduce it.
>> >=20
>> >=20
>> > Looks like that patch solved the /proc/net/tcp6 problem.  The caus=
al commit was=20
>> > the one you identified... confirmed with bisect.
>> >=20
>> > These warnings show up when I run the script (or I presume any tcp=
6 connection=20
>> > flooder) with /proc/sys/net/tcp/ipv4/tcp_tw_recycle enabled.  Ther=
e's textual=20
>> > corruption of the traces a lot of the time.  Here's a sample trace=
 that doesn't=20
>> > appear to be corrupt.  All the warnings I've seen are from route.c=
:209, and I=20
>> > don't see how that would cause memory corruption.
>>=20
>> Thats a different isse, already reported, under investigation.
>>=20
>> David did some changes recently
>>=20
>> http://comments.gmane.org/gmane.linux.network/179874
>>=20
>>=20
>>=20
>=20
> In my testings, I even have crashes in cleanup_once() if I
> enable /proc/sys/net/ipv4/tcp_tw_recycle=20

I'm looking into this, thanks guys.
