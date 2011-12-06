From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Tue, 06 Dec 2011 07:02:57 +0100
Message-ID: <1323151377.2467.13.camel@edumazet-laptop>
References: <30c2e9e0-4208-4c19-9e43-31f95e13575d@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63994 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603Ab1LFGDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 01:03:01 -0500
Received: by eeaq14 with SMTP id q14so2546617eea.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 22:03:00 -0800 (PST)
In-Reply-To: <30c2e9e0-4208-4c19-9e43-31f95e13575d@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 d=C3=A9cembre 2011 =C3=A0 23:10 -0500, John A. Sullivan III=
 a =C3=A9crit :
> Hello, all.  We are trying to minimize latency on our iSCSI SAN.  The
> network is entirely dedicated to the iSCSI traffic.  Since all the
> traffic is the same, would it make sense to change the qdisc for that
> interface to fifo from the default pfifo_fast or is the latency
> difference between the two completely negligible? Thanks - John

A very small difference indeed. How many packets per second are
expected ? What kind of NIC are you using ?
