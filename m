From: Kees Cook <keescook@chromium.org>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 22 May 2017 22:35:20 -0700
Message-ID: <CAGXu5jKDMUxRivMZdEQSBs81dkKRn5hRUiOz_wybCyphFFy+RQ@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <CAGXu5j+k+NMQGmmhuW-4pHFd6agfndJfxQ9k--h+ZpsDBVB8ig@mail.gmail.com>
 <8c53012b-cb81-5228-de79-f55457d1cf69@gmail.com> <CAHgaXdL2qReJF1Aw08k3C+OiC-3AOy3VeYmQ1Hs7vKcrfGQnvA@mail.gmail.com>
 <CAGXu5jKwTDYeNQggezzSKkFzZQkroC+6SdBB0qUKh5crfNk8PA@mail.gmail.com> <CAHgaXdKqt3mZmPG78w+4g_17D8EQoBgAZeuqM+MMsQg2f7apsw@mail.gmail.com>
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
Received: from mail-it0-f46.google.com ([209.85.214.46]:36900 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753820AbdEWFfW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:35:22 -0400
Received: by mail-it0-f46.google.com with SMTP id g126so13445191ith.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 22:35:21 -0700 (PDT)
In-Reply-To: <CAHgaXdKqt3mZmPG78w+4g_17D8EQoBgAZeuqM+MMsQg2f7apsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 10:03 PM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> On Tue, May 23, 2017 at 9:52 AM, Kees Cook <keescook@chromium.org> wrote:
>> On Mon, May 22, 2017 at 8:34 PM, Shubham Bansal
>> <illusionist.neo@gmail.com> wrote:
>>> I would post them as soon as I test them on ARMv5 and ARMv6. If you
>>> can help me with that, please let me know.
>>
>> Please post what you have: it would be better to see what you've got
>> now in case additional changes are needed so you don't have to do it
>> again on v5 and v6. Also, it means other people with real v5 and v6
>> hardware could test for you if they were so inclined, and you won't
>> need to be blocked on doing the tests in qemu.
>>
>> You can send it as an "RFC" in the subject, just to make sure people
>> know it's not considered fully done. :)
>
> I already have ARMv5 and ARMv6 code written. I just haven't tested it
> yet. Should i send the patch with those as well ?

Sure, just to have a version up for people to examine. If there are
bugs, that's fine, we'll iron them out.

-Kees

-- 
Kees Cook
Pixel Security
