From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [Linux-zigbee-devel] ieee802154: WARNING: at mm/page_alloc.c:2095
Date: Thu, 15 Dec 2011 15:21:24 +0300
Message-ID: <CAJmB2rCa-tODD9vFBRRY+Qp3DKDJN6VBLurE=TEqPatGFJEH4g@mail.gmail.com>
References: <1321948410.3787.3.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dbaryshkov@gmail.com, slapin@ossfans.org,
	davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:61756 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756143Ab1LOMV0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:21:26 -0500
Received: by lagp5 with SMTP id p5so875580lag.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 04:21:24 -0800 (PST)
In-Reply-To: <1321948410.3787.3.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sasha,

first of all could you please specify:
1. What's the kernel do you use?
2. What's the config options are enabled in your kernel?
3. What the HW do you use and what is the use case?
4. What you do to represent this error?

BTW: I cut linux-kernel list, not sure that it's suitable for such ques=
tions.

With best regards,
Alexander

2011/11/22 Sasha Levin <levinsasha928@gmail.com>:
> Hi all,
>
> I got the following warning when trying out ieee802154:
>
> [ =A0157.736372] WARNING: at mm/page_alloc.c:2095 __alloc_pages_nodem=
ask+0x177/0x722()
> [ =A0157.737707] Pid: 9100, comm: trinity Not tainted 3.2.0-rc2-sasha=
-00280-g45a222d #22
> [ =A0157.739114] Call Trace:
> [ =A0157.739559] =A0[<ffffffff810fcd7f>] ? __alloc_pages_nodemask+0x1=
77/0x722
> [ =A0157.740746] =A0[<ffffffff81086984>] warn_slowpath_common+0x7b/0x=
93
> [ =A0157.741824] =A0[<ffffffff81086a47>] warn_slowpath_null+0x15/0x17
> [ =A0157.743283] =A0[<ffffffff810fcd7f>] __alloc_pages_nodemask+0x177=
/0x722
> [ =A0157.744434] =A0[<ffffffff8112f8a3>] ? __slab_alloc.clone.46+0x42=
d/0x456
> [ =A0157.745598] =A0[<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0=
x151/0x197
> [ =A0157.747204] =A0[<ffffffff8112f8ab>] ? __slab_alloc.clone.46+0x43=
5/0x456
> [ =A0157.748375] =A0[<ffffffff810a4875>] ? sched_clock_local+0x12/0x7=
5
> [ =A0157.749475] =A0[<ffffffff81b96dd6>] ? __alloc_skb+0x42/0x14a
> [ =A0157.750682] =A0[<ffffffff810b2c3a>] ? lock_is_held+0x92/0x9d
> [ =A0157.751693] =A0[<ffffffff8112d399>] kmalloc_large_node+0x51/0x83
> [ =A0157.752757] =A0[<ffffffff81131ada>] __kmalloc_node_track_caller+=
0x29/0x127
> [ =A0157.753955] =A0[<ffffffff81b9449e>] ? sock_alloc_send_pskb+0xbd/=
0x2d7
> [ =A0157.755084] =A0[<ffffffff81b96e0a>] __alloc_skb+0x76/0x14a
> [ =A0157.756055] =A0[<ffffffff81b9449e>] sock_alloc_send_pskb+0xbd/0x=
2d7
> [ =A0157.757155] =A0[<ffffffff81b9e6ed>] ? rcu_read_unlock+0x21/0x23
> [ =A0157.758206] =A0[<ffffffff81b946c8>] sock_alloc_send_skb+0x10/0x1=
2
> [ =A0157.759292] =A0[<ffffffff81e18f4c>] dgram_sendmsg+0xa8/0x22c
> [ =A0157.760292] =A0[<ffffffff81e182af>] ieee802154_sock_sendmsg+0xf/=
0x11
> [ =A0157.761376] =A0[<ffffffff81b8fc6f>] __sock_sendmsg+0x65/0x72
> [ =A0157.762388] =A0[<ffffffff81b908bb>] sock_sendmsg+0xa3/0xbc
> [ =A0157.763351] =A0[<ffffffff810a4875>] ? sched_clock_local+0x12/0x7=
5
> [ =A0157.764420] =A0[<ffffffff8107ecfc>] ? get_parent_ip+0x11/0x41
> [ =A0157.765428] =A0[<ffffffff8107ecfc>] ? get_parent_ip+0x11/0x41
> [ =A0157.766439] =A0[<ffffffff810b2c3a>] ? lock_is_held+0x92/0x9d
> [ =A0157.767440] =A0[<ffffffff81141631>] ? fget_light+0x35/0x9e
> [ =A0157.768409] =A0[<ffffffff810a355f>] ? up_read+0x1e/0x35
> [ =A0157.769336] =A0[<ffffffff81b90479>] ? sockfd_lookup_light+0x1b/0=
x53
> [ =A0157.770434] =A0[<ffffffff81b91b1d>] sys_sendto+0x12d/0x16f
> [ =A0157.771396] =A0[<ffffffff810b1e8f>] ? trace_hardirqs_off_caller+=
0xa3/0x10b
> [ =A0157.772594] =A0[<ffffffff81e6fd1d>] ? retint_swapgs+0x13/0x1b
> [ =A0157.773599] =A0[<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0=
x151/0x197
> [ =A0157.774826] =A0[<ffffffff8161620e>] ? trace_hardirqs_on_thunk+0x=
3a/0x3f
> [ =A0157.775989] =A0[<ffffffff81e705d2>] system_call_fastpath+0x16/0x=
1b
>
> Please let me know if theres anything I can help with debugging it.
>
> --
>
> Sasha.
>
>
>
> ---------------------------------------------------------------------=
---------
> 10 Tips for Better Server Consolidation
> Server virtualization is being driven by many needs.
> But none more important than the need to reduce IT complexity
> while improving strategic productivity. =A0Learn More!
> http://www.accelacomm.com/jaw/sdnl/114/51507609/
> _______________________________________________
> Linux-zigbee-devel mailing list
> Linux-zigbee-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel
