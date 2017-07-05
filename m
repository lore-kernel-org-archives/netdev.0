From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Wed, 5 Jul 2017 15:38:20 -0700
Message-ID: <CAGXu5jJnGfmDYcistcx-o3MmKaB1vn8Fav62JURk9epYEOiTRA@mail.gmail.com>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com>
 <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com>
 <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
 <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com>
 <59419D1E.2060303@iogearbox.net> <CAHgaXdKMbFPgy-kKF0iDSAYo4CqLn9FRu9HwM+OfM-JWb9fNRQ@mail.gmail.com>
 <594813AA.5010001@iogearbox.net> <CAHgaXdLtX6yLdU3bMvS=g8FZ79sM_BW_+hHTMH=Mfk4TZqUnpw@mail.gmail.com>
 <59495367.3080402@iogearbox.net> <CAHgaXdKGJFh8jO44gwCqe0cijoztf39bK9k8ioBtYDjzb4vvZw@mail.gmail.com>
 <594A9FA5.1080003@iogearbox.net> <CAHgaXdKCOM++jdoaq9PV6a_bbRU+VyuLC4KeUdYmA0gYdhmhkQ@mail.gmail.com>
 <CAGXu5jJujrx3d+qM-50f1UCVxZopWzLCTJQpw3KWh+o4Nq9JOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJujrx3d+qM-50f1UCVxZopWzLCTJQpw3KWh+o4Nq9JOg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 5, 2017 at 3:11 PM, Kees Cook <keescook@chromium.org> wrote:
> On Fri, Jun 23, 2017 at 3:39 PM, Shubham Bansal
> <illusionist.neo@gmail.com> wrote:
>> Hi Russell,Daniel and Kees,
>>
>> I am attaching the latest patch with this mail. It included support
>> for BPF_CALL | BPF_JMP tested with and without constant blinding on
>> ARMv7 machine.
>> Due to the limitation on my machine I can't test the tail call. It
>> would be a great help if any of you could help me with this.
>
> Is this just a matter of running test_bpf?

If so:

Tested-by: Kees Cook <keescook@chromium.org>

test_bpf: Summary: 316 PASSED, 0 FAILED, [287/308 JIT'ed]

-Kees

-- 
Kees Cook
Pixel Security
