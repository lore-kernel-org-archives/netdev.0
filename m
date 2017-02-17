From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] pkt_sched: Remove useless qdisc_stab_lock
Date: Fri, 17 Feb 2017 10:02:30 -0800
Message-ID: <CAM_iQpVXMYg_ep8EvEXvRu6HbEdEydy8wZ-6_OQ=JMzWEVR-kA@mail.gmail.com>
References: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Feng Gao <gfree.wind@gmail.com>
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37206 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934140AbdBQSDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:03:19 -0500
Received: by mail-wm0-f50.google.com with SMTP id v77so15789511wmv.0
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 10:02:51 -0800 (PST)
In-Reply-To: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 10:34 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The qdisc_stab_lock is used in qdisc_get_stab and qdisc_put_stab.
> These two functions are invoked in qdisc_create, qdisc_change, and
> qdisc_destroy which run fully under RTNL.
>
> So it already makes sure only one could access the qdisc_stab_list at
> the same time. Then it is unnecessary to use qdisc_stab_lock now.

I posted a (almost) same patch two years ago:
http://marc.info/?l=linux-netdev&m=141512383516640&w=2

Forget why it was not accepted at that time.
