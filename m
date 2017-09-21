From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: remove cls_flower idr on failure
Date: Thu, 21 Sep 2017 11:47:44 -0700
Message-ID: <CAM_iQpX2QHqPFJ-vZz+6M4oDW2UgTbYdRuCxtNLm14S4sRVONg@mail.gmail.com>
References: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Chris Mi <chrism@mellanox.com>, Jiri Pirko <jiri@mellanox.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:45550 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdIUSsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:48:05 -0400
Received: by mail-pf0-f170.google.com with SMTP id z84so3641896pfi.2
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 11:48:05 -0700 (PDT)
In-Reply-To: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 9:18 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> +errout_idr:
> +       if (fnew->handle)
> +               idr_remove_ext(&head->handle_idr, fnew->handle);

Hmm, I should check fold instead of fnew->handle here.
I will update this patch.
