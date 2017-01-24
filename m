From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 21:10:34 -0700
Message-ID: <f494c25b-1ef0-1fe4-9ac5-05eafa903be0@cumulusnetworks.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <678f4d6f-e2f8-eb37-207a-c77269507f9d@cumulusnetworks.com>
 <CALCETrUz1701E5JS5NEqEqeGLExnxpesU44dSi2eYK4iMu=kcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33179 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXEKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:10:36 -0500
Received: by mail-pg0-f49.google.com with SMTP id 204so51052006pge.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:10:36 -0800 (PST)
In-Reply-To: <CALCETrUz1701E5JS5NEqEqeGLExnxpesU44dSi2eYK4iMu=kcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17 7:39 PM, Andy Lutomirski wrote:
> I'm not sure I followed what you meant.  If I understood right (which
> is a big if) you're saying that ip vrf when run in a netns works
> correctly in that netns.  I agree, but I think that it would continue
> to work (even more reliably) if the hooks only executed in the netns
> in which they were created.  I think that would probably be a good
> improvement, and it could be done on top of my patch, but I'm not
> about to write that code for 4.10.

Sounds like an efficiency on the implementation that does not require limiting the code today to just init namespace.
