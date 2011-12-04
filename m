From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 performance?
Date: Sun, 04 Dec 2011 22:50:02 +0100
Message-ID: <1323035402.2762.189.camel@edumazet-laptop>
References: <20111204211007.GA32098@hiwaay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Adams <cmadams@hiwaay.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49076 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269Ab1LDVuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 16:50:07 -0500
Received: by eaak14 with SMTP id k14so3707787eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 13:50:06 -0800 (PST)
In-Reply-To: <20111204211007.GA32098@hiwaay.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 d=C3=A9cembre 2011 =C3=A0 15:10 -0600, Chris Adams a =C3=
=A9crit :
> I have a system with an on-board RealTek gigabit network interface th=
at
> is giving me poor performance.  I'm using a simple test, running "nc =
-l"
> on one system and "dd if=3D/dev/zero | nc" on another.  I see about 2=
80
> Mbps transmit and 511 Mbps receive.


Do you mean that if this problematic NIC is the receiver, it receives
280Mbps, and if it is the sender, speed is 511 Mbps ?

Could you check counters ? =20

netstat -s
ethtool -S ethX
cat /proc/net/softnet_stat
