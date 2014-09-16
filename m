From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v2 1/4] net: sched: fix unsued cpu variable
Date: Tue, 16 Sep 2014 09:17:26 -0700
Message-ID: <CAHA+R7NgXAVTzvbE+WZvJ8VXC6J1pHP3+sggOJj=GZda_x17BA@mail.gmail.com>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:43942 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075AbaIPQR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:17:28 -0400
Received: by mail-lb0-f171.google.com with SMTP id 10so109713lbg.30
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:17:26 -0700 (PDT)
In-Reply-To: <20140916063024.2905.55403.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 11:30 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> kbuild test robot reported an unused variable cpu in cls_u32.c
> after the patch below. This happens when PERF and MARK config
> variables are disabled
>
> Fix this is to use separate variables for perf and mark
> and define the cpu variable inside the ifdef logic.
>
> 'commit 459d5f626da7 ("net: sched: make cls_u32 per cpu")'


Please use the Fixes: tag.


>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Other than that,

Acked-by: Cong Wang <cwang@twopensource.com>

Thanks!
