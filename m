From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/2] net_sched: move tc_action into tcf_common
Date: Thu, 21 Jul 2016 14:12:06 -0700
Message-ID: <CAM_iQpUMXAyAUH32tfN4gYShPmEMpJCk1H3beT9FtvhK4cFMaQ@mail.gmail.com>
References: <1469078614-13540-2-git-send-email-xiyou.wangcong@gmail.com> <201607220208.iT8LJ0gi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35458 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbcGUVM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 17:12:26 -0400
Received: by mail-it0-f65.google.com with SMTP id f6so1930740ith.2
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 14:12:26 -0700 (PDT)
In-Reply-To: <201607220208.iT8LJ0gi%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 11:35 AM, kbuild test robot <lkp@intel.com> wrote:
> All warnings (new ones prefixed by >>):
>
>    In file included from include/net/act_api.h:8:0,
>                     from net/sched/act_police.c:22:
>    net/sched/act_police.c: In function 'tcf_act_police_init':
>>> include/net/sch_generic.h:782:16: warning: 'police' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
>                    ^
>    net/sched/act_police.c:125:21: note: 'police' was declared here
>      struct tcf_police *police;

Yeah, I need to move police = to_police(*a); down after the following
goto label.

I will update this patch after waiting for comments from Jamal.
