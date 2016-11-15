From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Tue, 15 Nov 2016 10:26:50 +0100
Message-ID: <1479202010.4660.11.camel@redhat.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39202 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755468AbcKOJ0w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 04:26:52 -0500
In-Reply-To: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2016-11-14 at 15:24 -0800, Andrei Vagin wrote:
> Our test system detected a kernel oops. Looks like a problem in the
> "udp: refactor memory accounting" series.

My fault: I missed udplite in my tests.

Thank you for reporting.

I'm fine with Eric's patch, setting both .memory_allocated
and .sysctl_mem.
We could also remove .backlog_rcv, but it's not strictly needed.

Paolo
