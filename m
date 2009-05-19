From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 12:48:18 +0100
Message-ID: <298f5c050905190448g2cb0d26ft405a0b85a2f93d6a@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090515111227.7fc758cd@nehalam>
	 <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
	 <20090518091314.06bf60d2@nehalam> <20090518150234.0f57b263@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net,
	davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:23293 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbZESLsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 07:48:19 -0400
Received: by yx-out-2324.google.com with SMTP id 3so2360823yxj.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 04:48:19 -0700 (PDT)
In-Reply-To: <20090518150234.0f57b263@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Are you using one of the AMD dual core machines?  That processor has the bad
> design flaw that the TSC counter is not synced between core's so the kernel can't
> use it. You might even be better off running a non SMP kernel on that box.

My machine has two dual cores AMD Opteron processor 280. Do I have
that TSC problem.


# dmesg | grep AMD
OEM ID: AMD      Product ID: HAMMER       APIC at: 0xFEE00000
CPU0: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
CPU1: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
CPU2: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
CPU3: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02


processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 280
stepping        : 2
cpu MHz         : 2394.039
cache size      : 1024 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
fxsr_opt lm 3dnowext 3dnow pni lahf_lm cmp_legacy ts fid vid ttp
bogomips        : 4790.36
clflush size    : 64


  Antonio Almeida
