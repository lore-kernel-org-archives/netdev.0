From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: gretap IP fragmentation
Date: Fri, 22 Nov 2013 08:20:55 +0400
Message-ID: <284221385094055@web4m.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1m.mail.yandex.net ([37.140.138.1]:56076 "EHLO
	forward1m.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab3KVE05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 23:26:57 -0500
Received: from web4m.yandex.ru (web4m.yandex.ru [37.140.138.95])
	by forward1m.mail.yandex.net (Yandex) with ESMTP id 047BA1221EB3
	for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 08:20:55 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Trying to investigate problems transmitting IP packets of specific size
from gretap interface which is member of bridge device. To correctly
forward near-1500 byte L2 packets MTU of GRE-interface should be 1500.
But I don't understand why in case of IP packet tunnel code just copies
DF flag from the inner IP header to the outer header even when
"nopmtudisc" for gretap device is set? In this way fragmentation doesn'=
t
performed and packet silently dropped.

Is this an intentional behavior of gretap or some kind of bug?

Thank you!

--=20
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
=9A=9A=9A=9A=9A Alan Moore.
