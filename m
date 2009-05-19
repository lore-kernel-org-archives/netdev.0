From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 14:08:50 +0100
Message-ID: <298f5c050905190608q442d0c81l19b1aa4e579a259@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090515111227.7fc758cd@nehalam>
	 <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
	 <20090518091314.06bf60d2@nehalam> <20090518150234.0f57b263@nehalam>
	 <298f5c050905190448g2cb0d26ft405a0b85a2f93d6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net,
	davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:56048 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbZESNIt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 09:08:49 -0400
Received: by yx-out-2324.google.com with SMTP id 3so2385215yxj.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 06:08:50 -0700 (PDT)
In-Reply-To: <298f5c050905190448g2cb0d26ft405a0b85a2f93d6a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do I have that TSC problem?

On Tue, May 19, 2009 at 12:48 PM, Antonio Almeida <vexwek@gmail.com> wr=
ote:
>> Are you using one of the AMD dual core machines? =A0That processor h=
as the bad
>> design flaw that the TSC counter is not synced between core's so the=
 kernel can't
>> use it. You might even be better off running a non SMP kernel on tha=
t box.
>
> My machine has two dual cores AMD Opteron processor 280. Do I have
> that TSC problem.
>
>
> # dmesg | grep AMD
> OEM ID: AMD =A0 =A0 =A0Product ID: HAMMER =A0 =A0 =A0 APIC at: 0xFEE0=
0000
> CPU0: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
> CPU1: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
> CPU2: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
> CPU3: AMD Dual Core AMD Opteron(tm) Processor 280 stepping 02
>
>
> processor =A0 =A0 =A0 : 0
> vendor_id =A0 =A0 =A0 : AuthenticAMD
> cpu family =A0 =A0 =A0: 15
> model =A0 =A0 =A0 =A0 =A0 : 33
> model name =A0 =A0 =A0: Dual Core AMD Opteron(tm) Processor 280
> stepping =A0 =A0 =A0 =A0: 2
> cpu MHz =A0 =A0 =A0 =A0 : 2394.039
> cache size =A0 =A0 =A0: 1024 KB
> physical id =A0 =A0 : 0
> siblings =A0 =A0 =A0 =A0: 2
> core id =A0 =A0 =A0 =A0 : 0
> cpu cores =A0 =A0 =A0 : 2
> fdiv_bug =A0 =A0 =A0 =A0: no
> hlt_bug =A0 =A0 =A0 =A0 : no
> f00f_bug =A0 =A0 =A0 =A0: no
> coma_bug =A0 =A0 =A0 =A0: no
> fpu =A0 =A0 =A0 =A0 =A0 =A0 : yes
> fpu_exception =A0 : yes
> cpuid level =A0 =A0 : 1
> wp =A0 =A0 =A0 =A0 =A0 =A0 =A0: yes
> flags =A0 =A0 =A0 =A0 =A0 : fpu vme de pse tsc msr pae mce cx8 apic s=
ep mtrr pge
> mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
> fxsr_opt lm 3dnowext 3dnow pni lahf_lm cmp_legacy ts fid vid ttp
> bogomips =A0 =A0 =A0 =A0: 4790.36
> clflush size =A0 =A0: 64
>
>
> =A0Antonio Almeida
>
