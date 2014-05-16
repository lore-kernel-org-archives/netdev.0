From: Oleg A Arkhangelsky <sysoleg@yandex.ru>
Subject: Routing cache design question
Date: Fri, 16 May 2014 18:02:16 +0400
Message-ID: <657981400248936@web28j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward12.mail.yandex.net ([95.108.130.94]:48511 "EHLO
	forward12.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbaEPOCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 10:02:19 -0400
Received: from web28j.yandex.ru (web28j.yandex.ru [5.45.198.69])
	by forward12.mail.yandex.net (Yandex) with ESMTP id 10A2DC2079D
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 18:02:16 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Currently I'm studying routing cache on relatively old, pre- 3.6 kernel=
=2E I can't
understand why in some situations we don't just invalidate routing cach=
e with
new genid, but perform explicit full cleanup of all entries? Yes, I und=
erstand
that this is absolutely necessary when we unregister network device, ot=
herwise
kernel will spin inside netdev_wait_allrefs() till rt_check_expire() ki=
ll all
entries referencing this device. That's too long.

But why is this behavior necessary after, for example, device MTU chang=
e, or
physical link up/down (NETDEV_CHANGE) event?

Thank you!

--
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
=9A=9A=9A=9A=9A Alan Moore.
