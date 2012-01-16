From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why the number of /proc/interrupts doesn't change when nic is
 under heavy workload?
Date: Mon, 16 Jan 2012 07:53:28 +0100
Message-ID: <1326696808.5287.115.camel@edumazet-laptop>
References: <CAEc1PS0doeaH59621ia7n2GT=WgRSsCit_EzGrCV93QH95XZqw@mail.gmail.com>
	 <1326665367.5287.97.camel@edumazet-laptop>
	 <CAEc1PS0QxYfHfLFTiSFdTX27ufuxVfJd6Vg5oyv5aip5r=tD4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhxu@wayne.edu
To: Yuehai Xu <yuehaixu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEc1PS0QxYfHfLFTiSFdTX27ufuxVfJd6Vg5oyv5aip5r=tD4A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 15 janvier 2012 =C3=A0 17:27 -0500, Yuehai Xu a =C3=A9crit =
:
> Thanks for replying! Please see below:

> My memcached uses 8 different UDP sockets(8 different UDP ports), so
> there should be no lock contention for a single UDP rx-queue.

Ah, I missed this mail, so you really should post here result of "perf
top -C 0", after you make sure your NIC interrupts are handled by cpu 0=
=2E

Also, what speed is your link, and how many UDP messages per second do
you receive ?
