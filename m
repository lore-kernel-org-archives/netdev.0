From: Ronald Pina <pinaronald@gmail.com>
Subject: Re: Implementing Deficit Round Robin for different irtual interfaces
Date: Sun, 8 Feb 2015 22:14:41 +0100
Message-ID: <CAONBAadkef3UhU8Zhb04v11U58Di43e6XK3O8D=z3FTM0mmYCw@mail.gmail.com>
References: <CAONBAaeKZNCv42a+HY4TtXtYxnAr6-fX1GXEndKJ=r3nZ-1LhQ@mail.gmail.com>
	<CAA93jw5W+WwnWUWddksYSiuoVFkDvMCo3Vw6aiLK2Z3L4QTkGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34084 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbBHVOm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 16:14:42 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so12733316iga.0
        for <netdev@vger.kernel.org>; Sun, 08 Feb 2015 13:14:42 -0800 (PST)
In-Reply-To: <CAA93jw5W+WwnWUWddksYSiuoVFkDvMCo3Vw6aiLK2Z3L4QTkGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave
It is done a great work especially on bufferbload problem . On my work
i am trying to use this scheduling algorithm to schedule the virtual
network interfaces on Xen Hypervisor Dom0, maybe there are better
algorithm than DRR like DRR++ or the algorithm that you referenced,
but since it is a study work i would like to test the performance of
DRR and later can chose a better scheduling algorithm. The question is
that since tc tools in Linux are only for one device while on Xen the
traffic must be scheduled from different domains netif devices what is
the function or the module responsible for making scheduling
decisions?
 A similar idea is like using a qdisc to represent an netif network
virtual interface of guest on dom0.



On Sat, Feb 7, 2015 at 1:24 PM, Dave Taht <dave.taht@gmail.com> wrote:
> we have something better than drr already in the kernel.
>
> https://tools.ietf.org/html/draft-hoeiland-joergensen-aqm-fq-codel-01
>
> see also sch_fq
>
> as for fq over virtual devices....
>
> see recent posts on improving RPS steering.
>
> and regrettably FQ ignores cache locality and the cost of a context
> switch when taken too far. some batching (tso/gro/gso) is indeed
> required for a good compromise between latency and throughput.
>
> http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos#Dave-Ta=
umlhts-Water-Videos-November-2012

> --
> Dave T=C3=A4ht
>
> http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
