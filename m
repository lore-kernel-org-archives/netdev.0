From: mi wake <wakemi.wake@gmail.com>
Subject: rps testing questions
Date: Mon, 17 Jan 2011 17:43:26 +0800
Message-ID: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49067 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab1AQJn1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 04:43:27 -0500
Received: by gwj20 with SMTP id 20so1832314gwj.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 01:43:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do a rps(Receive Packet Steering) testing on centos 5.5 with  kernel =
2.6.37.
cpu: 8 core Intel.
ethernet adapter: bnx2x

Problem statement:
enable rps with:
echo "ff" > /sys/class/net/eth2/queues/rx-0/rps_cpus.

running 1 instances of netperf TCP_RR: netperf  -t TCP_RR -H 192.168.0.=
1 -c -C
without rps: 9963.48(Trans Rate per sec)
with rps:  9387.59(Trans Rate per sec)

I do ab and tbench testing also find there is less tps with enable
rps.but,there is more cpu using when with enable rps.when with enable
rps =A3=ACsoftirqs is blanced  on cpus.

is there something wrong with my test=A3=BF
