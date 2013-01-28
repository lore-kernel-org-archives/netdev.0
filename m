From: Duc Thinh Le <ducthinhle@yahoo.ca>
Subject: Flag this message TCP fragmentation on IPv6
Date: Mon, 28 Jan 2013 14:20:06 -0800 (PST)
Message-ID: <1359411606.93934.YahooMailClassic@web125402.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm35-vm7.bullet.mail.ne1.yahoo.com ([98.138.229.103]:36021 "EHLO
	nm35-vm7.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754532Ab3A1WZX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 17:25:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello TCP experts,

=A0 I am sorry to bother you. But I am just wondering if
=A0 you can shed some light on how TCP-v6 (Linux - Fedora)=20
  handle the case where it send a segment of 1500 bytes=20
  and then some router along the way sends back the=20
  ICMPv6 "too big - 1300" message. There are two choices:

=A0 =A0=A0=A01) TCPv6 resends the original segment (1500) into
=A0 =A0 =A0 =A0 two new TCP segments (one with 1300) and the other
=A0 =A0 =A0 =A0 is 200.

=A0 =A0 =A0 =A0 OR

=A0 =A0=A0=A02) TCPv6 sends out two IPv6 fragment packets to
=A0 =A0 =A0 =A0 achieve the original 1500

=A0 =A0 OR maybe, there are other ways as well. Thanks for your
=A0 times and helps. If there is a another forum that I can ask these
=A0 kinds of questions, please let me know. Thanks a lot.

Regards
Duc Le
