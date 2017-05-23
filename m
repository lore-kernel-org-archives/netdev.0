From: Kees Cook <keescook@google.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Tue, 23 May 2017 12:32:59 -0700
Message-ID: <CAGXu5j+DZ7+5zBh7s82AZPgDT=-WHo8bG6XwPT6SzaMtVMMn_Q@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <CAGXu5j+k+NMQGmmhuW-4pHFd6agfndJfxQ9k--h+ZpsDBVB8ig@mail.gmail.com>
 <8c53012b-cb81-5228-de79-f55457d1cf69@gmail.com> <CAHgaXdL2qReJF1Aw08k3C+OiC-3AOy3VeYmQ1Hs7vKcrfGQnvA@mail.gmail.com>
 <CAGXu5jKwTDYeNQggezzSKkFzZQkroC+6SdBB0qUKh5crfNk8PA@mail.gmail.com>
 <CAHgaXdKqt3mZmPG78w+4g_17D8EQoBgAZeuqM+MMsQg2f7apsw@mail.gmail.com>
 <CAGXu5jKDMUxRivMZdEQSBs81dkKRn5hRUiOz_wybCyphFFy+RQ@mail.gmail.com> <CAHgaXdJa9uJYO3bODuzDRaqOas0i=zMk0jioWFXKm_=UJRtVrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Network Development <netdev@vger.kernel.org>, ast@fb.com,
        Mircea Gherzan <mgherzan@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nicolas Schichan <nschichan@freebox.fr>, andrew@lunn.ch
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:36345 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936183AbdEWTdG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:33:06 -0400
Received: by mail-it0-f44.google.com with SMTP id o5so25967353ith.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:33:06 -0700 (PDT)
In-Reply-To: <CAHgaXdJa9uJYO3bODuzDRaqOas0i=zMk0jioWFXKm_=UJRtVrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 11:39 AM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> Here is the patch I sent to the arm mailing list.

Thanks for sending this!

I'm trying to figure out the best way to split this up, but the bulk
of it (the actual JIT changes) seems like they need to all land at the
same time. Any thoughts on this Daniel?

-Kees

-- 
Kees Cook
Pixel Security
