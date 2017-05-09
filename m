From: David Miller <davem@davemloft.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Tue, 09 May 2017 16:19:41 -0400 (EDT)
Message-ID: <20170509.161941.675253656642957586.davem@davemloft.net>
References: <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com>
        <58E639E0.1010700@iogearbox.net>
        <CAHgaXd+xb5dN90sH___RtxgSC3usnH2jXkA5r3=fQJc3pOY5xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, keescook@chromium.org, mgherzan@gmail.com,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com
To: illusionist.neo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753313AbdEIUTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 16:19:44 -0400
In-Reply-To: <CAHgaXd+xb5dN90sH___RtxgSC3usnH2jXkA5r3=fQJc3pOY5xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shubham Bansal <illusionist.neo@gmail.com>
Date: Wed, 10 May 2017 01:42:10 +0530

> Why is trying to execute TAX which is a cBPF instruction?

Because some of the tests are classic BPF programs which
get translated into eBPF ones and sent to the JIT for
compilation.
