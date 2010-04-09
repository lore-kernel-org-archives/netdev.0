From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange packet drops with heavy firewalling
Date: Fri, 09 Apr 2010 15:29:22 +0200
Message-ID: <1270819762.2623.97.camel@edumazet-laptop>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	 <1270813662.2623.85.camel@edumazet-laptop> <m3vdc0ztyc.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:61217 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab0DIN31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 09:29:27 -0400
Received: by bwz1 with SMTP id 1so2542144bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 06:29:26 -0700 (PDT)
In-Reply-To: <m3vdc0ztyc.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 avril 2010 =C3=A0 14:33 +0200, Benny Amorsen a =C3=A9cri=
t :

> Thank you very much for the help! I will report back whether it was t=
he
> hash buckets.

OK

You could try :

ethtool -C eth0 tx-usecs 200 tx-frames 100 tx-frames-irq 100
ethtool -C eth1 tx-usecs 200 tx-frames 100 tx-frames-irq 100

(to reduce tx completion irqs)


Before buying multiqueue devices, you also could try net-next-2.6 kerne=
l,
because RPS (Remote Packet Steering) is in.

In your setup, this might help a bit, distribute the packets to all cpu=
s,
with appropriate cache handling.



