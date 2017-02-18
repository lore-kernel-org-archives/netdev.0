From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 15:59:49 -0800
Message-ID: <CAADnVQKHiwpeF95abCoR2pOy+hnLLv2u4-qwe2dsnsBuTyiCRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36371 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdBSAAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:00:11 -0500
Received: by mail-wm0-f48.google.com with SMTP id c85so46867794wmi.1
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:00:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 3:48 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> We are running our vswitch in userspace now for many workloads
> it would be nice to have these in kernel if possible.
...
> Maybe Alex had something else in mind but we have many virtual interfaces
> plus physical interfaces in vswitch use case. Possibly thousands.

virtual interfaces towards many VMs is certainly good use case
that we need to address.
we'd still need to copy the packet from memory of one vm into another,
right? so per packet allocation strategy for virtual interface can
be anything.

Sounds like you already have patches that do that?
Excellent. Please share.
