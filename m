From: =?KOI8-R?B?9MXNxdLIwc7P1yDzxdLHxco=?= <temerkhanov@yandex.ru>
Subject: Fw: net: alignment problem in icmp code
Date: Sun, 21 Oct 2007 23:54:20 +0400
Message-ID: <306881192996460@webmail19.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: temerkhanov@cifronik.21th.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail19.mail.yandex.net ([213.180.200.53]:35022 "EHLO
	webmail19.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbXJUUBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 16:01:43 -0400
Received: from YAMAIL (webmail19) by mail.yandex.ru id S1745426AbXJUTyU for
        <netdev@vger.kernel.org>; Sun, 21 Oct 2007 23:54:20 +0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-------- =F0=C5=D2=C5=D3=D9=CC=C1=C5=CD=CF=C5 =D3=CF=CF=C2=DD=C5=CE=C9=C5=
 --------
21.10.07, 23:48, David Miller (davem@davemloft.net):

=46rom: Pierre Ossman <drzeus@drzeus.cx>
Date: Sun, 21 Oct 2007 11:34:05 +0200

> Inlining isn't the problem, but the defined semantics of assignment
> versus memcpy(). memcpy() must work on any region of memory, whilst
> assignment must only work on a properly aligned object.

You are missing a crucial point.

The compiler may emit the same exact loads and stores when it inlines
memcpy() if it "knows" the objects are aligned properly.  And it very
much will do this.

If the compiler is calling memcpy() in your build, it's only because
gcc believes the the object is too big to optimally memcpy() inline.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

-------- =FA=C1=D7=C5=D2=DB=C5=CE=C9=C5 =D0=C5=D2=C5=D3=D9=CC=C1=C5=CD=CF=
=C7=CF =D3=CF=CF=C2=DD=C5=CE=C9=D1 --------


--
"=EB=D2=C1=D3=CB=C9 =CF=D3=C5=CE=C9": =EE=CF=D7=D9=CA =CB=CF=CE=CB=D5=D2=
=D3 =CE=C1 =F1=CE=C4=C5=CB=D3.=E6=CF=D4=CB=C1=C8 http://fotki.yandex.ru=
/contest.xml?id=3D10
