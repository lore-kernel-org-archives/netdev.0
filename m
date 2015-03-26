From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 14:16:40 +0100
Message-ID: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33791 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbbCZNQm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 09:16:42 -0400
Received: by lbcmq2 with SMTP id mq2so40575291lbc.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 06:16:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, hope this is the right place to ask.

Does anyone know if there is work beeing done in natively supporting
IPv6 nexthops for IPv4?

I know that "some" Linux switch software company is working on this, bu=
t
I am afraid the functionality will be more of a "hack".

The benefit of this is stateless configuration (rfc5549), using IPv6 li=
nk-local
neighbor address as IPv4 nexthop, beeing able to do for example:

ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev sfp0

This is somehow possible now by exploiting static arp entries and
"unused" IPv4 addresses for nexthop, but is far from ideal.

Hope someone will be able to provide some insight on what is planned
in this area, and weather this direct functionality will ever make it
into the kernel.

--
Bj=C3=B8rnar Ness
