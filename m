From: thomas yang <lampsu@gmail.com>
Subject: IP header identification field is zero, why?
Date: Wed, 7 Oct 2009 22:04:34 +0800
Message-ID: <f4f837ab0910070704k7a193be9i285573b423b96ba2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:35583 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759058AbZJGOFL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 10:05:11 -0400
Received: by iwn8 with SMTP id 8so2835872iwn.33
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 07:04:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is captured on my PC (Fedora 11, Linux=A3=A9

[root@localhost ~]# tcpdump -i eth1 icmp -n -x
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
17:02:39.025882 IP 192.168.1.64 > 192.168.1.1: ICMP echo request, id
25096, seq 1, length 64
	0x0000:  4500 0054 0000 4000 4001 b717 c0a8 0140
=2E.....
17:02:39.027866 IP 192.168.1.64 > 192.168.1.1: ICMP echo request, id
25096, seq 2, length 64
	0x0000:  4500 0054 0000 4000

The  IP header 'identification' field is zero, why?

I wrote a simple UDP server and UDP client programs, and captured some
packets, the IP identification is also zero.

Should the host increase this field for each packet it sends?


I captured some TCP packets, all of the IP identification are
different, not zero.


--
thomas
