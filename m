From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: Still problems receving multicasts with r8169.c driver from linux  kernel (2.6.22.1) + patches
Date: Mon, 16 Jul 2007 15:23:07 +0200
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062DFD@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([213.33.59.122]:26821 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762731AbXGPN2R convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 09:28:17 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

sorry, i 4got to add the netdev-cc should not happen again ;-)

I still cannot access some patches (maybe u get them via browser cache =
or no right restrictions?)

So, i added all your patches(1-21) from the bz2 file in the root-dir to=
 a plain driver from 2.6.22.1 ...

=46act is: I still have missing multicast packet income, but things cha=
nged:

before i had one good try within 20, now i get my packet stream every s=
econd to 3rd try.

Descrition what i do:

i'm sending multicast packets (e.g. Dstn IP 224.1.13.1 port 10501) ever=
y 8,9ms the packetlen is 496 bytes (it's a RTP stream) to my linux syst=
em and monitor incoming packets with tcpdump -i eth0 (and my applicatio=
n of course)

What i get now is, almost every 2nd attempt i start transmitting packet=
s i get them just fine (without any drops between) on the other side on=
 some attempts i start sending and i see no incoming multicast packets =
with tcpdump (as well as from within the receiving application)

routes look OK, netstat -g shows correct memberships

Greetings
Robert


-----Urspr=FCngliche Nachricht-----
Von: Francois Romieu [mailto:romieu@fr.zoreil.com]
Gesendet: Montag, 16. Juli 2007 13:05
An: Reither Robert
Betreff: Re: Problems receving multicasts with r8169.c driver from linu=
x
kernel (2.6.21.5)


Is there a specific reason why you did not Cc: netdev@vger.kernel.org ?

Reither Robert <Robert.Reither@av-digital.at> :
[...]
> Tested now with latest official kernel (2.6.22.1), happens the same w=
ay.

Ok. It's the expected result.

> Will now try to add the patches ...
>=20
>=20
> Can you give me a hint, which patch exactly could fix my problem ?

0020, 0021 and probably some bits of the merge with Realtek's driver.

Start gross and apply everything. It takes something along the lines of=
:
cat series | while read f; do patch -p1 $f; done

> Btw, some patches from your link
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628=
/
> are not accessable (3, 9, 13, 18)

I have tried the four url below and they downloaded correctly:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/0=
003-r8169-kill-eth_copy_and_sum.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/0=
009-r8169-prettify-mac_version.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/0=
013-r8169-small-8101-comment.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/0=
018-r8169-add-endianess-annotations-to-RT-xDesc.patch

Can you check your command line or grep the tarball in the upper direct=
ory ?

> -----Urspr=FCngliche Nachricht-----

Please avoid TOFU.

--=20
Ueimor
