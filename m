From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: profile my proto_hook.function
Date: Tue, 12 Apr 2011 16:03:46 +0200
Message-ID: <1302617026.3233.49.camel@edumazet-laptop>
References: <BANLkTi==HczThr66Yr0-Rm-RkEUw44sqrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42833 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258Ab1DLODv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:03:51 -0400
Received: by wya21 with SMTP id 21so5718185wya.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 07:03:48 -0700 (PDT)
In-Reply-To: <BANLkTi==HczThr66Yr0-Rm-RkEUw44sqrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 22:00 +0800, zhou rui a =C3=A9crit :
> hi
> I used a prot_hook(added via dev_add_pack,protocol=3DETH_P_ALL) to
> process packets in kernel part.but the performance was bad
>=20
> ksoftirqd used almost 100% cpu on my 1G nic(intel e1000,w/o RSS) XEON
> 5400 hypertown machine.
>=20
> looks my  packet processing is too slow. but how to profile this?
> i.e. how many CPU resources used in softirq and normal kernel protoco=
l
> stack(tcp/ip,etc)
> and how many used in my packet processing function?
>=20
> and any idea to improve it?how about moving the processing function t=
o driver?

You coud use perf tool, included in kernel sources

# cd ~your_kernel_sources
# cd tools/perf
# make

<run your workload, and record activity :>
# ./perf record -a -g sleep 10

Then later, you can take a look at results

=2E/perf report



