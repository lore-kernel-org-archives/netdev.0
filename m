From: Benoit PAPILLAULT <benoit.papillault@free.fr>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP packets
Date: Sun, 10 Jan 2010 18:43:56 +0100
Message-ID: <4B4A11DC.9070706@free.fr>
References: <bug-14837-10286@http.bugzilla.kernel.org/>	 <20091218153209.45042a58.akpm@linux-foundation.org>	 <1261227303.11973.2.camel@bigi>  <4B2ECCAB.8010702@free.fr>	 <1261422543.8201.6.camel@bigi>  <4B45EFF3.50006@free.fr> <1263139437.11273.13.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:46631 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753686Ab0AJRoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 12:44:01 -0500
In-Reply-To: <1263139437.11273.13.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jamal,

jamal a =E9crit :
> Salut Benoit,
>
> I didnt see any patch...
>
> Also did you try changing the mtu per suggestion i made?
>  =20
I cannot changed the MTU by design since I need to have the gretap=20
interface be part of an Ethernet bridge.
> People tend to be busy and sometimes dont read the mailing list. To
> get proper answers, always CC the maintainers. In this case CC Stephe=
n
> Hemminger - he maintains the bridging code. I am ccing Herbert Xu as
> well - he may have opinions on the gre side of things. My suggestion =
is
> you repost your issue along with your patch and describe why it solve=
s
> your problem.
>  =20
I know people can be busy, I am just trying to push things forward.=20
Original bug is there :
http://bugzilla.kernel.org/show_bug.cgi?id=3D14837

Patch is available here :
http://bugzilla.kernel.org/attachment.cgi?id=3D24332

This patch fixes my issue since either packets get fragmented or an ICM=
P=20
error packet is sent back to the sender.

Regards,
Benoit
PS: Congrats to Herbert Xu which fixes a bug in gretap before I had the=
=20
time to report it (was about the broadcast addr which was incorrect).

> cheers,
> jamal
>
>  =20

