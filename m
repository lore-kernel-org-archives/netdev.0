From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH] net: sched: cls_cgroup need tcf_exts_init in all cases
Date: Tue, 16 Sep 2014 09:26:39 -0700
Message-ID: <CAHA+R7O8RL3tOa4pTHcA9Npp9zs13zJZk8q-Oasa2TSTR4qTvA@mail.gmail.com>
References: <20140916073341.2597.36240.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:54691 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbaIPQ0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:26:41 -0400
Received: by mail-lb0-f172.google.com with SMTP id w7so137823lbi.3
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:26:39 -0700 (PDT)
In-Reply-To: <20140916073341.2597.36240.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 12:33 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This ensures the tcf_exts_init() is called for all cases.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Fixes: commit 952313bd62589cae216a57 ("net: sched: cls_cgroup use RCU")
Acked-by: Cong Wang <cwang@twopensource.com>
