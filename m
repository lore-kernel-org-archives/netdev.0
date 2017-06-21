From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Wed, 21 Jun 2017 21:53:27 +0200
Message-ID: <594ACEB7.2030707@iogearbox.net>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com> <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com> <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com> <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com> <59419D1E.2060303@iogearbox.net> <CAHgaXdKMbFPgy-kKF0iDSAYo4CqLn9FRu9HwM+OfM-JWb9fNRQ@mail.gmail.com> <594813AA.5010001@iogearbox.net> <CAHgaXdLtX6yLdU3bMvS=g8FZ79sM_BW_+hHTMH=Mfk4TZqUnpw@mail.gmail.com> <59495367.3080402@iogearbox.net> <CAHgaXdKGJFh8jO44gwCqe0cijoztf39bK9k8ioBtYDjzb4vvZw@mail.gmail.com> <594A9FA5.1080003@iogearbox.net> <CAHgaXdKm6atQ=XkrQf+ShKtPU7=H+pS2VvPsTXXhz2yzOFunmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHgaXdKm6atQ=XkrQf+ShKtPU7=H+pS2VvPsTXXhz2yzOFunmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/2017 09:37 PM, Shubham Bansal wrote:
> Hi Daniel,
>
> Good news. Got the CALL to work.
>
> [  145.670882] test_bpf: Summary: 316 PASSED, 0 FAILED, [287/308 JIT'ed]
>
> Awesome. Do you think with this implementation, the patch could get
> accepted? If you think so, then I will send the patch in couple of
> days after some refactoring, if not, then do let me know what more is
> required?

Nice, it's ultimately up to the arm folks to review the set in-depth,
but feel free to send out the patch once you're done refactoring. With
BPF_CALL support that looks quite good from pov of supported insns.
