From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Interpreting perf stat on netperf and netserver
Date: Thu, 19 Jan 2012 10:24:08 +0100
Message-ID: <1326965048.2249.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:46230 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756325Ab2ASJYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 04:24:13 -0500
Received: by lahc1 with SMTP id c1so2757574lah.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 01:24:12 -0800 (PST)
In-Reply-To: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 12:33 +0100, Jean-Michel Hautbois a
=C3=A9crit :

> The be2net driver seems to have difficulties woth IRQ affinity also,
> because it always uses CPU0 even if the affinity is 0-23 !
> netperf result is quite good, and perf top shows :
>    PerfTop:     689 irqs/sec  kernel:99.6% us: 0.3% guest kernel: 0.0=
%
> guest us: 0.0% exact:  0.0% [1000Hz cycles],  (all, 24 CPUs)
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
--------------------------------------
>=20
>     29.28%  [kernel]          [k] csum_partial
>      8.46%  [kernel]          [k] copy_user_generic_string
>      3.70%  [be2net]          [k] be_poll_rx
>      3.08%  [be2net]          [k] event_handle
>      2.37%  [kernel]          [k] irq_entries_start
>      2.21%  [be2net]          [k] be_rx_compl_get
>      1.65%  [be2net]          [k] be_post_rx_frags
>      1.64%  [kernel]          [k] __napi_complete
>      1.50%  [kernel]          [k] ip_defrag
>      1.35%  [kernel]          [k] put_page
>      1.34%  [kernel]          [k] get_page_from_freelist
>      1.29%  [kernel]          [k] __netif_receive_skb
>      1.16%  [kernel]          [k] __alloc_pages_nodemask
>      1.14%  [kernel]          [k] debug_smp_processor_id
>      1.08%  [kernel]          [k] add_preempt_count
>      1.06%  [kernel]          [k] sub_preempt_count
>      1.03%  [be2net]          [k] get_rx_page_info
>      1.01%  [kernel]          [k] alloc_pages_current
>=20
> Checksum calculation seems quite complex :).

UDP with fragments... I guess... but cant see this in the perf top
output ;)

What bandwidth do you get for this cpu load ?
