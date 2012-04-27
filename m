From: =?ISO-8859-15?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: sky2 still badly broken
Date: Fri, 27 Apr 2012 22:15:10 +0200
Message-ID: <4F9AFE4E.8010108@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:54052 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759754Ab2D0UYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 16:24:36 -0400
Received: from [192.168.2.8] (unknown [192.168.2.8])
	by mail.linuxsystems.it (Postfix) with ESMTPSA id 15591141B8
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 22:14:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dmesg is full of

[ 1464.914044] sky2 0000:06:00.0: eth0: rx error, status 0x5220002=20
length 1314
[ 1465.005628] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 532
[ 1465.204459] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 532
[ 1465.825909] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 532
[ 1468.715858] net_ratelimit: 3 callbacks suppressed
[ 1468.715865] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 532

dhcp does not work (after a few minutes it does not renew the ip)

while under heavy load the card resets and I have to unload and reload=20
the module

also transfer rate is VERY low.

lowering the mtu does help a bit, but it doesn't make miracles...

kernel 3.4.0-rc4

06:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8055 PCI-=
E=20
Gigabit Ethernet Controller (rev 13)

http://forums.gentoo.org/viewtopic-t-487018-start-0-postdays-0-postorde=
r-asc-highlight-.html

Thanks,
Niccol=F2
