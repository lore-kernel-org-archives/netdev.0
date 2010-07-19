From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 19:41:59 +0200
Message-ID: <1279561319.2553.153.camel@edumazet-laptop>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46612 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760747Ab0GSRmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 13:42:05 -0400
Received: by wyb42 with SMTP id 42so4611025wyb.19
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 10:42:03 -0700 (PDT)
In-Reply-To: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 10:05 -0700, Tom Herbert a =C3=A9crit :
> We have been looking at best case TCP latencies that might be achieve=
d
> within a cluster (low loss fabric).  The goal is to have latency
> numbers roughly comparable to that which can be produced using RDMA/I=
B
> in a low latency configuration  (<5 usecs round trip on netperf TCP_R=
R
> test with one byte data for directly connected hosts as a starting
> point).  This would be without changing sockets API, fabric, and
> preferably not using TCP offload or a user space stack.
>=20
> I think there are at least two techniques that will drive down TCP
> latency: per connection queues and polling queues.  Per connection
> queues (supported by device) should eliminate costs of connection
> look-up, hopefully some locking.  Polling becomes viable as core
> counts on systems increase, and burning a few CPUs for networking
> polling on behalf of very low-latency threads would be reasonable.
>=20
> Are there any efforts in progress to integrate per connection queues
> in the stack or integrate polling of queues?

aka "net channel" ;)

What a nightmare...

Anyway, 5 us roundtrip TCP_RR (including user thread work), seems a bit
utopic right now.

Even on loopback



