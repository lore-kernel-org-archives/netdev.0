From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Sat, 19 Jul 2014 18:02:13 -0400
Message-ID: <53CAEAE5.3090300@mojatatu.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>	 <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>	 <53C7C675.7090400@mojatatu.com>	 <CAM_iQpU6=rtb+-T9NiiEJ+799PtJo=j1=EBuAL76Ac7=w=MKHA@mail.gmail.com>	 <1405621030.10255.84.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAM_iQpUgDurOWfXHdx_aTBS2L0h1QWUFe-du3W6CsZw8jfaF7w@mail.gmail.com>	 <1405661823.10255.86.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAM_iQpWO-SS0rEVp+Nmxd9N8O0UvtpufVj8ozc3csStuVtKshA@mail.gmail.com> <1405667332.10255.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:64218 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaGSWC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 18:02:27 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so4889410wgh.10
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 15:02:26 -0700 (PDT)
In-Reply-To: <1405667332.10255.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/14 03:08, Eric Dumazet wrote:
> On Thu, 2014-07-17 at 22:51 -0700, Cong Wang wrote:
>
> If this conversion was already done by John, I would have pointed the
> patch to finalize.
>
> There is nothing fundamental that requires this spinlock being held in
> fast path.
>
> It is perfectly possible to remove this, and first step is to use RCU,
> then percpu counters.
>

I think rcufication would help in some the shared action instances.
Note: post John's rcu-fication of classifier path this is not an
issue i.e
the most common use case default behavior (majority) is no sharing of
instances - in such a case there is no lock contention.

cheers,
jamal
