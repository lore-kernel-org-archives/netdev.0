From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: sched: fix missing free per cpu on qstats
Date: Tue, 5 Jan 2016 18:49:42 -0800
Message-ID: <CAM_iQpW9qCOuFGAKDY0e=qsT_PY-CdU3FyNK0tA2cRVkxAwAZw@mail.gmail.com>
References: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
	<1452015851.8255.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33648 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbcAFCtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 21:49:43 -0500
Received: by mail-yk0-f176.google.com with SMTP id k129so280479534yke.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 18:49:42 -0800 (PST)
In-Reply-To: <1452015851.8255.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 5, 2016 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-01-05 at 09:11 -0800, John Fastabend wrote:
>> When a qdisc is using per cpu stats (currently just the ingress
>> qdisc) only the bstats are being freed. This also free's the qstats.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> David, please add the following tag to ease backports to stable kernels:
>
> Fixes: 22e0f8b9322cb ("net: sched: make bstats per cpu and estimator RCU safe")
>

Not a big deal at all but... doesn't that fix commit b0ab6f92752b9f9d8
instead of 22e0f8b9322cb?
