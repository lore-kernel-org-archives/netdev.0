From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: bpf bounded loops. Was: [flamebait] xdp
Date: Fri, 2 Dec 2016 10:39:04 -0800
Message-ID: <20161202183903.GC54949@ast-mbp.thefacebook.com>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36014 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752356AbcLBSjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:39:09 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so8607899pgx.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:39:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 10:27:12PM +0100, Hannes Frederic Sowa wrote:
> like") and the problematic of parsing DNS packets in XDP due to string
> processing and looping inside eBPF.

Hannes,
Not too long ago you proposed a very interesting idea to add
support for bounded loops without adding any new bpf instructions and
changing llvm (which was way better than my 'rep' like instructions
I was experimenting with). I thought systemtap guys also wanted bounded
loops and you were cooperating on the design, so I gave up on my work and
was expecting an imminent patch from you. I guess it sounds like you know
believe that bounded loops are impossible or I misunderstand your statement ?

As far as pattern search for DNS packets...
it was requested by Cloudflare guys back in March:
https://github.com/iovisor/bcc/issues/471
and it is useful for several tracing use cases as well.
Unfortunately no one had time to implement it yet.
