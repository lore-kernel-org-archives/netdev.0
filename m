From: nello martuscielli <ppc.addon@gmail.com>
Subject: Re: iproute-3.8.0 build error on Linux ppc64
Date: Wed, 27 Feb 2013 06:39:35 +0100
Message-ID: <CABMX=Wwfsn6GSc1NSw1zc1V9z12x2Z7HJ9-KxL=NiYFuCV-7BA@mail.gmail.com>
References: <CABMX=WwSNeTq_ascBRxJtQrsErR-cFODZQh_wrim6K8weyLDtQ@mail.gmail.com>
	<CABMX=WwQNmNPsfZHvMYq9p9W_Q1RbZ=bpTCcv5AN=wD0CGSqmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:41787 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab3B0Fjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 00:39:36 -0500
Received: by mail-vb0-f48.google.com with SMTP id fc21so14503vbb.35
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 21:39:35 -0800 (PST)
In-Reply-To: <CABMX=WwQNmNPsfZHvMYq9p9W_Q1RbZ=bpTCcv5AN=wD0CGSqmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry, it was the previous commit about -Werror

 thanks,
 Nell



On Wed, Feb 27, 2013 at 6:15 AM, nello martuscielli <ppc.addon@gmail.com> wrote:
> hi,
> after  commit:
> http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff;h=6398d3a65277a2ebed085ad9deef15fea6f4ed09
>
> specifically -Wmissing-prototypes and I get this error on Linux ppc64
>
> [...]
> gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
> -Wmissing-declarations -Wold-style-definition -O2 -I../include
> -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
> -D_GNU_SOURCE   -c -o ipneigh.o ipneigh.c
> gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
> -Wmissing-declarations -Wold-style-definition -O2 -I../include
> -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
> -D_GNU_SOURCE   -c -o ipntable.o ipntable.c
> cc1: warnings being treated as errors
> ipntable.c: In function 'print_ntable':
> ipntable.c:435:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:488:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:492:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:496:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:505:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:509:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:539:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:543:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:551:4: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:563:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:564:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:565:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:570:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:571:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:572:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:577:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:578:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:583:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> ipntable.c:584:3: error: format '%llu' expects type 'long long
> unsigned int', but argument 3 has type '__u64'
> make[1]: *** [ipntable.o] Error 1
> make[1]: Leaving directory `/root/iproute2-3.8.0/ip'
> make: *** [all] Error 2
>
>
> my system is IBM POWER4+ with a CRUX PPC 3.0alpha (64bit).
>
>
> thanks,
> Nell
> --
> my blog: http://linuxpowerpc.blogspot.com/



-- 
--
Power Mac G4 AGP 450MHz - CRUX PPC (32bit)
