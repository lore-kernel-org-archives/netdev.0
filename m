From: cold cold <nedkonedev@gmail.com>
Subject: 0% cpu usasge after fresh boot or net restart but 10% CPU if kernel
	flush route cache
Date: Tue, 26 Jan 2010 18:58:31 +0200
Message-ID: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:18251 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab0AZQ6c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 11:58:32 -0500
Received: by fg-out-1718.google.com with SMTP id 22so102770fge.1
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 08:58:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI,


i have expiriance some CPU usage spikes=A0up to 10% on=A0each four cpus
after the=A0first kernel route cache flush.
After mashine start first 20 min CPU is 0%si=A0=A0300Mbits/s full duple=
x
and arount 100k pps forwarded traffic, without any firewall, just
plain routing.

route -n |wc -l
34

ip route show cache | wc -l
2140842

cat /proc/sys/net/ipv4/route/secret_interval
600
cat /proc/sys/net/ipv4/route/max_size
33554432

after kernel=A0 flush i got 10% on all CPUs for 5-6 mins.=A0 It's not f=
rom
rebuilding route cashe becouse=A0after
fresh boot or network restrat there is no=A0CPU usage until kernel flus=
h
route cache.
I try to play with rhash_entries=3D 300000=A0to 2000000 same result.

Network Card: Ethernet controller: Intel Corporation 82576 Gigabit
Network Connection
CPU: Intel(R) Xeon(R) CPU=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 E5420=A0 @ 2.50=
GHz
RAM: 4G
Kernel: vanilla=A02.6.32.4
