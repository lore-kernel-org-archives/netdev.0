From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Tue, 15 Nov 2016 15:07:20 +0100
Message-ID: <1479218840.4660.18.camel@redhat.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
         <1479202010.4660.11.camel@redhat.com>
         <1479218524.8455.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrei Vagin <avagin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933752AbcKOOHW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:07:22 -0500
In-Reply-To: <1479218524.8455.123.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-15 at 06:02 -0800, Eric Dumazet wrote:
> On Tue, 2016-11-15 at 10:26 +0100, Paolo Abeni wrote:
> > Hi,
> > 
> > On Mon, 2016-11-14 at 15:24 -0800, Andrei Vagin wrote:
> > > Our test system detected a kernel oops. Looks like a problem in the
> > > "udp: refactor memory accounting" series.
> > 
> > My fault: I missed udplite in my tests.
> > 
> > Thank you for reporting.
> > 
> > I'm fine with Eric's patch, setting both .memory_allocated
> > and .sysctl_mem.
> > We could also remove .backlog_rcv, but it's not strictly needed.
> 
> That is a good point, can you cook the official combined patch ?

Sure, I'll send ASAP, after a little testing.
