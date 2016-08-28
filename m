From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Sun, 28 Aug 2016 08:23:26 -0400
Message-ID: <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        davem@davemloft.net, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:37456 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755421AbcH1MX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 08:23:28 -0400
Received: by mail-it0-f48.google.com with SMTP id d65so61173282ith.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 05:23:28 -0700 (PDT)
In-Reply-To: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-27 03:11 AM, John Fastabend wrote:
> From: Alexei Starovoitov <ast@fb.com>
>
> This patch adds initial support for XDP on e1000 driver. Note e1000
> driver does not support page recycling in general which could be
> added as a further improvement. However for XDP_DROP and XDP_XMIT
> the xdp code paths will recycle pages.
>
> This patch includes the rcu_read_lock/rcu_read_unlock pair noted by
> Brenden Blanco in another pending patch.
>
>   net/mlx4_en: protect ring->xdp_prog with rcu_read_lock

Do you have any perf numbers of drops of this vs tc drop at ingress?
single or multiple cpus.

cheers,
jamal
