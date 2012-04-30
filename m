From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 still badly broken
Date: Mon, 30 Apr 2012 12:25:01 -0700
Message-ID: <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47411 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756574Ab2D3TZE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 15:25:04 -0400
In-Reply-To: <4F9AFE4E.8010108@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Apr 2012 22:15:10 +0200
Niccol=F2 Belli <darkbasic@linuxsystems.it> wrote:

> dmesg is full of
>=20
> [ 1464.914044] sky2 0000:06:00.0: eth0: rx error, status 0x5220002=20
> length 1314
> [ 1465.005628] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
> length 532
> [ 1465.204459] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
> length 532
> [ 1465.825909] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
> length 532
> [ 1468.715858] net_ratelimit: 3 callbacks suppressed
> [ 1468.715865] sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
> length 532
>=20
> dhcp does not work (after a few minutes it does not renew the ip)
>=20
> while under heavy load the card resets and I have to unload and reloa=
d=20
> the module
>=20
> also transfer rate is VERY low.
>=20
> lowering the mtu does help a bit, but it doesn't make miracles...
>=20
> kernel 3.4.0-rc4
>=20
> 06:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8055 PC=
I-E=20
> Gigabit Ethernet Controller (rev 13)
>=20
> http://forums.gentoo.org/viewtopic-t-487018-start-0-postdays-0-postor=
der-asc-highlight-.html

You are getting CRC and FIFO overrun errors. What laptop is this?
Everything works fine on my old Fuijitsu with same chip (but rev 14).
You could try taking out the status bit checks and see if the
packets are really okay and the Marvell chip is complaining about
bogus status.


The Gentoo thread is so old as to be meaningless and unrelated.
