From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Tue, 09 Feb 2010 08:20:36 +0100
Message-ID: <1265700036.4236.120.camel@edumazet-laptop>
References: <1265639549.3048.33.camel@edumazet-laptop>
	 <1265657560.4236.80.camel@edumazet-laptop>
	 <20100208152606.91c55722.akpm@linux-foundation.org>
	 <20100208.153406.123254133.davem@davemloft.net>
	 <20100208153744.236158aa.akpm@linux-foundation.org>
	 <20100208155053.4ad68484@nehalam>
	 <1265695598.4236.95.camel@edumazet-laptop>
	 <20100208223540.3cdabe44.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57827 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517Ab0BIHUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 02:20:43 -0500
Received: by bwz19 with SMTP id 19so522515bwz.28
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 23:20:40 -0800 (PST)
In-Reply-To: <20100208223540.3cdabe44.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 22:35 -0800, Andrew Morton a =C3=A9=
crit :
> On Tue, 09 Feb 2010 07:06:38 +0100 Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>=20
> > After this patch, I believe that scheduler is allowed to migrate
> > dst_gc_task() to an idle cpu.
>=20
> No, keventd threads are each pinned to a single CPU (kthread_bind() i=
n
> start_workqueue_thread()), so dst_gc_task() gets run on the CPU which
> ran schedule_delayed_work() and no other.
>=20

Ah OK, thanks Andrew for this clarification.

I suppose offlining a cpu migrates its works to another (online) cpu ?



