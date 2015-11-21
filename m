From: "Eugene A. Kravtsov" <ek@oborona.net>
Subject: Linux 3.16.7: WARNING at kernfs_get+0x2a/0x30() and ida_remove+0xdd/0x120() in loop
Date: Sat, 21 Nov 2015 17:34:57 +0500
Message-ID: <1764882558.20151121173457@oborona.net>
Reply-To: =?windows-1251?B?yvDg4vbu4iDF4uPl7ejpIMDr5erx4O3k8O7i6Pc=?=
	  <ek@oborona.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Guillaume Nault <g.nault@alphalink.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tms04.deltatelesystems.ru ([91.206.16.9]:44945 "EHLO
	tms04.deltatelesystems.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbbKUMnN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 07:43:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Last week I have a problem with kernel update my PPPoE BRAS server
from Linux 3.2.0-4-686-pae #1 SMP Debian 3.2.68-1+deb7u1 i686 GNU/Linux
to  3.16.0-4-686-pae #1 Debian  3.16.7-ckt11-1+deb8u5.
At  any  time,  for  no reason, at any load server downed to oops with following
trace http://spec.oborona.net/bras_panic

Server  software  is:  rp-pppoe + pppoe + tc htb shapers on ppp interfaces
called  from  ip-ip  script.  No  special  settings are not using.

I tried to install new debian kernel 4.2.6, but the problem is not solved,
everything became worse, server worked with 4.2.6 about 15 minutes and downed to panic
(no trace - network rsyslog is empty).

After that, i decide to try stable kernel from kernel.org - 4.2.3,
and saw the same panic with no network logs as with 4.2.6.

Many  technical  staff from Russia and UA ISP confirmed these problems
with ppp in all new kernels (accell-ppp and rp-pppoe).
https://translate.google.ru/translate?hl=ru&sl=ru&tl=en&u=http%3A%2F%2Fforum.nag.ru%2Fforum%2Findex.php%3Fshowtopic%3D45266%26st%3D6220
This is the same our problem from UA colleague http://www.spinics.net/lists/netdev/msg352992.html

Last  kernel with no problem, for me - 3.2.68-1+deb7u1 i686 GNU/Linux.
With 3.2 kerel server uptime is infinite.

Can i help with additional information?
