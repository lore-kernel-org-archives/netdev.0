From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP echo reply fails
Date: Fri, 26 Mar 2010 23:06:30 +0100
Message-ID: <1269641190.2256.1.camel@edumazet-laptop>
References: <2acbd3e41003261448q26cb19d4w63487894b24f0254@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65386 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656Ab0CZWGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 18:06:36 -0400
Received: by bwz1 with SMTP id 1so2186544bwz.21
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 15:06:34 -0700 (PDT)
In-Reply-To: <2acbd3e41003261448q26cb19d4w63487894b24f0254@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 mars 2010 =C3=A0 16:48 -0500, Andy Fleming a =C3=A9crit =
:
> For various reasons, we have been running a stress test on one of our
> boards.  The test consists of initiating 2-3 flood pings from a
> Windows box running Cygwin, plus one additional ping we use as a
> "heartbeat".  The ping flood is overwhelming our board (we're droppin=
g
> packets at a prodigious rate), but the board continues to respond for
> a while.  In addition, we are running a script on the  board which
> alternates bringing up and bringing down the interface every ten
> seconds.  After a highly variable amount of time, the board stops
> replying to the pings.  We suspected a driver issue, however, on
> closer inspection, we are still able to send and receive packets (I
> can ping *from* the board to the PC, and I can *telnet* from the PC t=
o
> the board).  We tried pinging the board from another PC, and it also
> failed.  Essentially, ICMP echo requests are being ignored (A glance
> at memory indicates that packets are arriving, but no packets are
> being enqueued to the ethernet controller).  We still have a lot more
> debugging to do, but I was wondering if anyone had ever seen somethin=
g
> like this, or might be quicker to realize the obvious mistake we're
> making.
>=20
> Thanks,
> Andy Fleming


kernel version ?

NIC driver ?

Are ICMP echo request received ? (grep Icmp /proc/net/snmp)


