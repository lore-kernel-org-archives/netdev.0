From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Thu, 06 Apr 2017 14:51:44 +0200
Message-ID: <58E639E0.1010700@iogearbox.net>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com> <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com> <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com> <20170315.145512.1542025976162251828.davem@davemloft.net> <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com> <58DAF908.8010404@iogearbox.net> <CAHgaXdKfbob3WHMho32JSh_dmfp2A=cjcePqk+NfajVpShPE6Q@mail.gmail.com> <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35015 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753213AbdDFMvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:51:54 -0400
In-Reply-To: <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2017 01:05 PM, Shubham Bansal wrote:
> Gentle Reminder.

Sorry for late reply.

> Anybody can tell me how to test the JIT compiler ?

There's lib/test_bpf.c, see Documentation/networking/filter.txt +1349
for some more information. It basically contains various test cases that
have the purpose to test the JIT with corner cases. If you see a useful
test missing, please send a patch for it, so all other JITs can benefit
from this as well. For extracting disassembly from a generated test case,
check out bpf_jit_disasm (Documentation/networking/filter.txt +486).

Thanks,
Daniel
