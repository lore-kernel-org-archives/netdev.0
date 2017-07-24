From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [BUG] /net/hsr: prune_timer
Date: Mon, 24 Jul 2017 14:03:30 -0700
Message-ID: <CAM_iQpX96_Q_dQdoC4kEN4DXjmYgjgoLJY7JeT9qx_oLj++ZWg@mail.gmail.com>
References: <op.y3kbi1pqlevu92@dandreev01.uni-eng.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dmitry <d.andreev@uni-eng.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35165 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756314AbdGXVDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:03:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id r77so921675wmd.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 14:03:52 -0700 (PDT)
In-Reply-To: <op.y3kbi1pqlevu92@dandreev01.uni-eng.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 1:07 AM, Dmitry <d.andreev@uni-eng.ru> wrote:
> Hello!
>
>
> void hsr_prune_nodes(unsigned long data) called once by timer.
>
> hsr_prune_nodes must be called periodically every PRUNE_PERIOD (60s).
>
>
>
>
> This code want be added to tail of hsr_prune_nodes function
>
> hsr->prune_timer.expires = jiffies + msecs_to_jiffies(PRUNE_PERIOD);
> add_timer(&hsr->prune_timer);
>
> or
>
> mod_timer(&hsr->prune_timer, jiffies + msecs_to_jiffies(PRUNE_PERIOD));

Please feel free to send a patch.

You can follow this doc:
https://www.kernel.org/doc/html/v4.11/process/submitting-patches.html


Thanks!
