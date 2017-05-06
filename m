From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Sat, 6 May 2017 22:18:16 +0530
Message-ID: <CAHgaXdK1XjDnhTqtk=nCq2crrigHiuCaLhF+1GupJt9bPThwZw@mail.gmail.com>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com>
 <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
 <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com>
 <20170315.145512.1542025976162251828.davem@davemloft.net> <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com>
 <58DAF908.8010404@iogearbox.net> <CAHgaXdKfbob3WHMho32JSh_dmfp2A=cjcePqk+NfajVpShPE6Q@mail.gmail.com>
 <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com> <58E639E0.1010700@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34051 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751836AbdEFQsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:48:17 -0400
Received: by mail-oi0-f50.google.com with SMTP id b204so15539452oii.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:48:17 -0700 (PDT)
In-Reply-To: <58E639E0.1010700@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

Thanks for the last reply about the testing of eBPF JIT.

I have one issue though, I am not able to find what BPF_ABS and
BPF_IND instruction does exactly. It not described on this link -
https://www.kernel.org/doc/Documentation/networking/filter.txt either.
Can you please tell me where I could find the description of these
instructions please?
Best,
Shubham Bansal


On Thu, Apr 6, 2017 at 6:21 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 04/06/2017 01:05 PM, Shubham Bansal wrote:
>>
>> Gentle Reminder.
>
>
> Sorry for late reply.
>
>> Anybody can tell me how to test the JIT compiler ?
>
>
> There's lib/test_bpf.c, see Documentation/networking/filter.txt +1349
> for some more information. It basically contains various test cases that
> have the purpose to test the JIT with corner cases. If you see a useful
> test missing, please send a patch for it, so all other JITs can benefit
> from this as well. For extracting disassembly from a generated test case,
> check out bpf_jit_disasm (Documentation/networking/filter.txt +486).
>
> Thanks,
> Daniel
