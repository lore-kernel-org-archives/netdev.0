From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Fri, 11 Aug 2017 13:18:08 -0700
Message-ID: <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35423 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753181AbdHKUS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:18:29 -0400
Received: by mail-pg0-f48.google.com with SMTP id v189so19471600pgd.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 13:18:29 -0700 (PDT)
In-Reply-To: <150235751251.493255.14955523507789154918.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> In previous API tcf_destroy_chain() could be called several times and
> some schedulers like hfsc and atm use that. In new API tcf_block_put()
> frees block but leaves stale pointer, second call will free it once again.

Which call path do we call tcf_block_put() for multiple times on
the same block? Please be specific, it is not obvious.
