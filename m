From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Tue, 15 Nov 2016 06:02:04 -0800
Message-ID: <1479218524.8455.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
         <1479202010.4660.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrei Vagin <avagin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32921 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932176AbcKOOCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 09:02:06 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so11934219pgd.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 06:02:06 -0800 (PST)
In-Reply-To: <1479202010.4660.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-15 at 10:26 +0100, Paolo Abeni wrote:
> Hi,
> 
> On Mon, 2016-11-14 at 15:24 -0800, Andrei Vagin wrote:
> > Our test system detected a kernel oops. Looks like a problem in the
> > "udp: refactor memory accounting" series.
> 
> My fault: I missed udplite in my tests.
> 
> Thank you for reporting.
> 
> I'm fine with Eric's patch, setting both .memory_allocated
> and .sysctl_mem.
> We could also remove .backlog_rcv, but it's not strictly needed.

That is a good point, can you cook the official combined patch ?

Thanks !
