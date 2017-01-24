From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 20:16:18 -0800
Message-ID: <CALCETrXhUxe67xKCMzrkXd14qcZ1rukFGFObYkjCFsDcvAqNgw@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com> <678f4d6f-e2f8-eb37-207a-c77269507f9d@cumulusnetworks.com>
 <CALCETrUz1701E5JS5NEqEqeGLExnxpesU44dSi2eYK4iMu=kcQ@mail.gmail.com> <f494c25b-1ef0-1fe4-9ac5-05eafa903be0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:32795 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXEQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:16:40 -0500
Received: by mail-ua0-f180.google.com with SMTP id i68so125515949uad.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:16:40 -0800 (PST)
In-Reply-To: <f494c25b-1ef0-1fe4-9ac5-05eafa903be0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 8:10 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 1/23/17 7:39 PM, Andy Lutomirski wrote:
>> I'm not sure I followed what you meant.  If I understood right (which
>> is a big if) you're saying that ip vrf when run in a netns works
>> correctly in that netns.  I agree, but I think that it would continue
>> to work (even more reliably) if the hooks only executed in the netns
>> in which they were created.  I think that would probably be a good
>> improvement, and it could be done on top of my patch, but I'm not
>> about to write that code for 4.10.
>
> Sounds like an efficiency on the implementation that does not require limiting the code today to just init namespace.
>

It's an ABI change, not an implementation change.  If someone wants to
make the code fully netns-aware in time for 4.10, that sounds great.
I'm not going to do that.
