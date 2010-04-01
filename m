From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Increased Latencies when upgrading kernel version
Date: Thu, 01 Apr 2010 23:19:01 +0200
Message-ID: <1270156741.2192.14.camel@edumazet-laptop>
References: <o2vd585dc4f1004011212s65cc2beewed2f19321210a249@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Taylor Lewick <taylor.lewick@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:47633 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0DAVTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 17:19:06 -0400
In-Reply-To: <o2vd585dc4f1004011212s65cc2beewed2f19321210a249@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 14:12 -0500, Taylor Lewick a =C3=A9crit :
> For some time now we've been running an older kernel, 2.6.16.60.  Whe=
n
> we tried to upgrade, first going to 2.6.27.19 and then to 2.6.32.1 an=
d
> 2.6.33.1 we noticed that latencies increased.  At first we noticed it
> by doing network tests via udpping, netperf, etc.  We made some
> tweaks, and were able to get network latency to within 1 to 2
> microseconds of where we were previously on 2.6.16.60.  Then we did
> some more testing, and noticed that system latency also seems higher.
>=20
> We've done our tests on identical hardware servers, same NICs,
> connected through same network gear.  Basically, we've tried to keep
> everything identical except the kernel versions, and we are unable to
> achieve the same performance for system latency on the newer kernels,
> despite adjusting various kernel settings and recompiling.
>=20
> The latency differences are about 15 microseconds per transaction.
>=20
> At this point, I don't know what else to try.  I haven't played aroun=
d
> with the /proc/sys/kernel/sched_* paramaters under the newer kernels
> yet.  Have tried changing pre-emption modes with little effect, in
> fact, voluntary preemption seems to be peforming the best for us.
>=20
> At this time the realtime patch isn't really an option for us to
> consider, at least not yet.
>=20
> Any suggestions?  Is this a known issue when upgrading to more recent
> kernel versions?
>=20

Hi Taylor

Well, this is bit difficult to generically answer to your generic
question. 15 us more latency per transaction seems pretty bad.

Some inputs would be nice, describing your workload and
software/hardware architecture.

lspci
cat /proc/cpuinfo
cat /proc/interrupts
dmesg
ethtool -S eth0
ethtool -c eth0



