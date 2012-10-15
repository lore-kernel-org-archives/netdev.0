From: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 12:32:31 +0200
Message-ID: <CAO_aot5PesW1VsnUdRpBpiRJ_awDVZN6WoN=8q7JKSb3+=R0-g@mail.gmail.com>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	<1350242941.21172.17023.camel@edumazet-glaptop>
	<CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	<1350244485.21172.17077.camel@edumazet-glaptop>
	<CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	<1350246314.21172.17139.camel@edumazet-glaptop>
	<1350246414.21172.17144.camel@edumazet-glaptop>
	<1350246481.21172.17147.camel@edumazet-glaptop>
	<CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	<1350248858.21172.17197.camel@edumazet-glaptop>
	<CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	<1350250542.21172.17229.camel@edumazet-glaptop>
	<CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	<1350252091.21172.17257.camel@edumazet-glaptop>
	<CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	<1350279753.21172.17290.camel@edumazet-glaptop>
	<1350293136.21172.17527.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:64549 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab2JOKcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 06:32:31 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so3549535iag.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 03:32:31 -0700 (PDT)
In-Reply-To: <1350293136.21172.17527.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm, another strange thing in your STRACE file is :
>
>
> 12928 open("/proc/net/if_inet6", O_RDONLY) = 6
> 12928 fstat(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
> 12928 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> -1, 0) = 0x7fc54a719000
> 12928 lseek(6, 0, SEEK_SET)             = 0
> 12928 read(6, "fe80000000000000922b34fffe33c292"..., 1024) = 54
>
>
> So /proc/net/if_inet6 doesnt include lo device on your machine ?
>
>
>

@Jan Ceuleers: Thank you, for your explanation!

@Eric Dumazet: I will be at home in some hours and will check the
/proc/net/if_inet6 file.
I can offer you to compile some code reversions. I even looked at the
changes at kernelnewbies.org/LinuxChanges but did not know where to
start.
