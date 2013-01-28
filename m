From: "Freddy" <freddy@asix.com.tw>
Subject: RE: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0 to gigabit ethernet adapter driver
Date: Mon, 28 Jan 2013 21:36:20 +0800
Message-ID: <010f01cdfd5c$768d4240$63a7c6c0$@asix.com.tw>
References: <1358908337-13841-1-git-send-email-freddy@asix.com.tw>	<20130127001347.584711b2@xenia> <87zjztptez.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <louis@asix.com.tw>,
	<davem@davemloft.net>, <Support@asix.com.tw>
To: "=?utf-8?Q?'Bj=C3=B8rn_Mork'?=" <bjorn@mork.no>,
	"'Michael Leun'" <lkml20130126@newton.leun.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([210.243.224.51]:51892 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287Ab3A1Ni3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 08:38:29 -0500
In-Reply-To: <87zjztptez.fsf@nemi.mork.no>
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I would vote to not accept that driver for mainline as long as this=20
> issues are not fixed.


Michael, could you give me more information about how do you test this =
driver?=20
I have tried to reproduce the issue by using "ifconfig ethX mtu 1500", =
but I didn't confront the same issue.
Thank you in advance for your help.


> The vendor should not be able to claim "hooray, hooray, great device,=
=20
> we even have an driver in linux main line" when it is actually such a=
n=20
> useless crap.

> Well, that is fortunately not how these things work. The main goal is=
 getting the devices supported in the kernel. Bugs can be fixed.  If a =
vendor can get any positive gain out of having a driver in mainline, th=
en that is good for everyone, isn't it?  Of course, we can all agree th=
at the > > > effect of a *working* driver is more positive than a non-w=
orking driver...


> For now, the main focus should be fixing the issues which has been no=
ted during review.  Your testing feedback is of course very useful, but=
 you probably need to back them up with actual code change proposals if=
 they are going to be dealt with at this stage.

> Of course I'm offering to help with any information or testing, but=20
> unfortunately I do not have the knowhow to fix anything myself.

> I believe this is where you are totally wrong.  You obviuously have t=
he ability to create a few simple test cases for yourself and see if th=
e driver behaves as you expect.  That is very useful.

> And you have a device.  That is also useful.

> Now, the driver source code is available.  And there is another Asix =
driver in the kernel which already has been cleaned up and can be used =
as an example. And maybe even partly used for the new devices as well, =
if the code is duplicated?  I have not looked at this in detail, but I =
    > suspect that much of the problem with the ax88179_178a driver is =
that it has completely ignored all the work that has gone into the asix=
 driver after it was mainlined.  I find it unlikely that there is no re=
usable code in the asix_devices.c, asix_common.c and ax88172a.c files. =
 Trying to > rewrite ax88179_178a to share as much code as possible see=
ms like the best way to clean it up and fix bugs.

Bj=C3=B8rn, I am trying to reproduce the issue mentioned by Michael and=
 I have a question about submitting this driver.
Should I merge this driver into asix_devices.c and asix_common.c even t=
hrough the usb command, tx_fixup, and rx_fixup functions are totally di=
fferent?
Thank you in advance for your reply.

=46reddy
