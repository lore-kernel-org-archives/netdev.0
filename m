From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Thu, 17 Jul 2014 14:25:17 -0700
Message-ID: <CAM_iQpUgDurOWfXHdx_aTBS2L0h1QWUFe-du3W6CsZw8jfaF7w@mail.gmail.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
	<1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
	<53C7C675.7090400@mojatatu.com>
	<CAM_iQpU6=rtb+-T9NiiEJ+799PtJo=j1=EBuAL76Ac7=w=MKHA@mail.gmail.com>
	<1405621030.10255.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:53101 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaGQVZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 17:25:18 -0400
Received: by mail-oa0-f45.google.com with SMTP id i7so1645205oag.4
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 14:25:17 -0700 (PDT)
In-Reply-To: <1405621030.10255.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 11:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Anyway, tcfm_dev should probably be RCU protected.
>

Not sure how much we gain from making it RCU. We anyway
need to hold that spinlock on fast path since we need to
update its time stamp and stats.

I would just leave it as is.
