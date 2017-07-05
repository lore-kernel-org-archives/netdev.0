From: Jamie Bainbridge <jamie.bainbridge@gmail.com>
Subject: Re: [Patch net] tcp: reset sk_rx_dst in tcp_disconnect()
Date: Wed, 5 Jul 2017 16:54:01 +1000
Message-ID: <CAAvyFNitoxhPpivWaY+qgW+ssVxvt-3O+4eBfYCN81a0Dn7JZg@mail.gmail.com>
References: <1498373430-24807-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, avagin@gmail.com, kaiwen.xu@hulu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34349 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdGEGyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 02:54:02 -0400
Received: by mail-pg0-f46.google.com with SMTP id t186so120210021pgb.1
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 23:54:02 -0700 (PDT)
In-Reply-To: <1498373430-24807-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 June 2017 at 16:50, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> We have to reset the sk->sk_rx_dst when we disconnect a TCP
> connection, because otherwise when we re-connect it this
> dst reference is simply overridden in tcp_finish_connect().
>
> This fixes a dst leak which leads to a loopback dev refcnt
> leak. It is a long-standing bug, Kevin reported a very similar
> (if not same) bug before. Thanks to Andrei for providing such
> a reliable reproducer which greatly narrows down the problem.
>
> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Reported-by: Kevin Xu <kaiwen.xu@hulu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Are you able to supply the reproducer for this?

I did search for a previous thread about it but could not find.

Jamie
