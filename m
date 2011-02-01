From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Tue, 1 Feb 2011 16:08:02 +0530
Message-ID: <AANLkTin+MkXrqpkcKxUbMk9UDAtYz3H02Ka+CjGxJQRB@mail.gmail.com>
References: <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
	<AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
	<20110118012146.GA3704@electric-eye.fr.zoreil.com>
	<AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
	<20110127150744.GA7925@electric-eye.fr.zoreil.com>
	<AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>
	<20110127165031.GA7966@electric-eye.fr.zoreil.com>
	<AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com>
	<20110128120624.GA8100@electric-eye.fr.zoreil.com>
	<1296479698.8750.55.camel@ceranb.intra.cera.cz>
	<20110201101253.GA8681@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org,
	Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38007 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab1BAKiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 05:38:05 -0500
Received: by bwz15 with SMTP id 15so6161859bwz.19
        for <netdev@vger.kernel.org>; Tue, 01 Feb 2011 02:38:03 -0800 (PST)
In-Reply-To: <20110201101253.GA8681@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 1, 2011 at 3:42 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Ivan Vecera <ivecera@redhat.com> :
> [...]
>> Unfortunately I have no local access (it's placed in China) or remote
>> serial console to the system with this 8168c. The second problem is that
>> the system is connected to the switch that does not pass the packets
>> with VLAN tags -> it seems that at least Tx packets have the VLAN tag.
>>
>> I'm sorry I'm not able to help more.
>
> Thanks a lot for the information, it is both welcome and helpful.
>
> I'll freeze Anand's report for now as "8168c + unspecified glue hardware
> bug with unknown product manufactured by Arkino on unidentified motherboard
> with unknown number of processors".

 cat /proc/cpuinfo
processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 16
model		: 6
model name	: AMD Sempron(tm) 140 Processor
stepping	: 2
cpu MHz		: 2700.641
cache size	: 1024 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 5
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt pdpe1gb
rdtscp lm 3dnowext 3dnow constant_tsc up nonstop_tsc extd_apicid pni
monitor cx16 popcnt lahf_lm svm extapic cr8_legacy abm sse4a
misalignsse 3dnowprefetch osvw ibs skinit wdt npt lbrv svm_lock
nrip_save
bogomips	: 5401.28
clflush size	: 64
cache_alignment	: 64
address sizes	: 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate



>
> --
> Ueimor
>
