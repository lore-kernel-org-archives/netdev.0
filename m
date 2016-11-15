From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Mon, 14 Nov 2016 16:31:26 -0800
Message-ID: <1479169886.8455.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
         <1479166501.8455.91.camel@edumazet-glaptop3.roam.corp.google.com>
         <CANaxB-yYy1vstc-D6GAD=HKjHy68UHQvVukXQSf02MjMvhSxhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Paolo Abeni <pabeni@redhat.com>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34238 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755161AbcKOAhR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 19:37:17 -0500
Received: by mail-pg0-f52.google.com with SMTP id x23so56962560pgx.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 16:37:16 -0800 (PST)
In-Reply-To: <CANaxB-yYy1vstc-D6GAD=HKjHy68UHQvVukXQSf02MjMvhSxhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 15:58 -0800, Andrei Vagin wrote:

> 
> Yes, you are right. It works if we set .memory_allocated and .sysctl_mem.

Now the question would be :

Are we okay if UDP and UDPlite share the same limits ?

I would vote for yes, because these default limits are huge anyway
(The 50% reduction done in
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=b66e91ccbc34ebd5a2f90f9e1bc1597e2924a500
only impacted TCP )
