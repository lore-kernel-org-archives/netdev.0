From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Thu, 6 Jul 2017 21:42:12 -0700
Message-ID: <CAGXu5j+yfOFU2xULwkQmp0Jz5pzLiurRSQ14kwGetBycdgF0Hg@mail.gmail.com>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com>
 <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com>
 <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
 <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com>
 <59419D1E.2060303@iogearbox.net> <CAHgaXdKMbFPgy-kKF0iDSAYo4CqLn9FRu9HwM+OfM-JWb9fNRQ@mail.gmail.com>
 <594813AA.5010001@iogearbox.net> <CAHgaXdLtX6yLdU3bMvS=g8FZ79sM_BW_+hHTMH=Mfk4TZqUnpw@mail.gmail.com>
 <59495367.3080402@iogearbox.net> <CAHgaXdKGJFh8jO44gwCqe0cijoztf39bK9k8ioBtYDjzb4vvZw@mail.gmail.com>
 <594A9FA5.1080003@iogearbox.net> <CAHgaXdKCOM++jdoaq9PV6a_bbRU+VyuLC4KeUdYmA0gYdhmhkQ@mail.gmail.com>
 <CAGXu5jJujrx3d+qM-50f1UCVxZopWzLCTJQpw3KWh+o4Nq9JOg@mail.gmail.com>
 <CAGXu5jJnGfmDYcistcx-o3MmKaB1vn8Fav62JURk9epYEOiTRA@mail.gmail.com> <CAHgaXd+ywWu6PjnqGGdyw=7=XTKm4_Ny227Eq7yH5N0s0e5YfA@mail.gmail.com>
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
In-Reply-To: <CAHgaXd+ywWu6PjnqGGdyw=7=XTKm4_Ny227Eq7yH5N0s0e5YfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 5, 2017 at 8:49 PM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> Hi Kees,
>
> Problem is my ARM machine don't have clang and iproute2 which is
> keeping me from testing the bpf tail calls.
>
> You should do the following to test it,.
>
> 1. tools/testing/selftests/bpf/
> 2. make
> 3. sudo ./test_progs
>
> And, before testing, you have to do "make headers_install".
> These tests are for tail calls with the attached patch. If its too
> much work, Can you please upload your arm image so that I can test it?
> I just need a good machine.

I've got all this set up now, and it faults during the test:

Unable to handle kernel NULL pointer dereference at virtual address 00000008
...
CPU: 0 PID: 1922 Comm: test_progs Not tainted 4.12.0+ #60
...
PC is at __htab_map_lookup_elem+0x54/0x1f4

I'll see if I can send you this disk image...

-Kees


-- 
Kees Cook
Pixel Security
