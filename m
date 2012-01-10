From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Iproute2 build broken by current kernel headers
Date: Tue, 10 Jan 2012 10:54:09 -0800
Message-ID: <20120110105409.3567bb1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44966 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755940Ab2AJSyM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 13:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The update to inet diag broke compatibility with exported headers.
Iproute2 uses sanitized kernel headers.

gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_=
HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ss.o ss.c
ss.c: In function =E2=80=98tcp_show_netlink=E2=80=99:
ss.c:1504:7: error: =E2=80=98struct inet_diag_req=E2=80=99 has no membe=
r named =E2=80=98idiag_family=E2=80=99
make[1]: *** [ss.o] Error 1
make[1]: Leaving directory `/home/shemminger/src/iproute2/misc'
