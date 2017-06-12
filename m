From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Tue, 13 Jun 2017 01:17:14 +0200
Message-ID: <593F20FA.6010505@iogearbox.net>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com> <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com> <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
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
In-Reply-To: <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2017 05:40 PM, Shubham Bansal wrote:
[...]
>> Did you manage to get tail calls tested as well (I assume so since you
>> implemented emit_bpf_tail_call() in the patch but just out of curiosity)?
>
> I didn't try it exclusively, I thought test_bpf must have tested it. Doesn't it?

In samples/bpf/ there's sockex3* that would exercise it, or
alternatively in iproute2 repo under examples/bpf/ there's
bpf_cyclic.c and bpf_tailcall.c as a prog.

Hm, generally, we should really add a test case also to BPF
selftest suite to facilitate that. I'll likely do that for
the next batch of BPF patches.
