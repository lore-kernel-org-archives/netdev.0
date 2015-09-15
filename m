From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v3 net 0/5] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 15 Sep 2015 11:16:14 -0700
Message-ID: <20150915181614.GA15698@kafai-mba.local>
References: <1441994781-2718585-1-git-send-email-kafai@fb.com>
 <20150914.194925.1193918139295619388.davem@davemloft.net>
 <20150914.195637.558611773755031925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<hannes@stressinduktion.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57991 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751532AbbIOSQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 14:16:28 -0400
Content-Disposition: inline
In-Reply-To: <20150914.195637.558611773755031925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 07:56:37PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 14 Sep 2015 19:49:25 -0700 (PDT)
>
> > Series applied, thanks Martin.
>
> Actually, reverted, this doesn't even compile :-/
>
> In file included from include/linux/srcu.h:33:0,
>                  from include/linux/notifier.h:15,
>                  from include/linux/memory_hotplug.h:6,
>                  from include/linux/mmzone.h:812,
>                  from include/linux/gfp.h:5,
>                  from include/linux/kmod.h:22,
>                  from include/linux/module.h:13,
>                  from net/ipv6/ip6_tunnel.c:23:
> net/ipv6/ip6_tunnel.c: In function =E2=80=98ip6_tnl_per_cpu_dst_set=E2=
=80=99:
> net/ipv6/ip6_tunnel.c:135:35: error: invalid type argument of =E2=80=98=
->=E2=80=99 (have =E2=80=98seqlock_t=E2=80=99)
>         lockdep_is_held(&idst->lock->lock)));
Sorry about that. I will fix it and repost.
