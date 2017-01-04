From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2] net/sched: cls_matchall: Fix error path
Date: Tue, 3 Jan 2017 22:33:44 -0800
Message-ID: <CAM_iQpXR6GvuFRtF05d6LPigP5fZHP8X=JwOE84+Cc1M=R=1gA@mail.gmail.com>
References: <1483464024-25745-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>, eladr@mellanox.com,
        Jiri Pirko <jiri@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34951 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965512AbdADGeF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 01:34:05 -0500
Received: by mail-qt0-f196.google.com with SMTP id 3so38670781qtr.2
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 22:34:05 -0800 (PST)
In-Reply-To: <1483464024-25745-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2017 at 9:20 AM, Yotam Gigi <yotamg@mellanox.com> wrote:
> Fix several error paths in matchall:
>  - Release reference to actions in case the hardware fails offloading
>    (relevant to skip_sw only)
>  - Fix error path in case tcf_exts initialization/validation fail
>
> Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Looks good,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
