From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Mon, 21 Aug 2017 03:46:05 +0530
Message-ID: <CAHgaXdKFtv9GUWJZBpTkbq807a+=rJRJ+fk3rKqPW1Jhjert3A@mail.gmail.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com> <599A0961.3010300@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>, Andrew Lunn <andrew@lunn.ch>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <599A0961.3010300@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> With the below #ifdef __LITTLE_ENDIAN spanning the entire
> bpf_int_jit_compile(), a user can then enable and compile
> eBPF JIT for big endian, even set the bpf_jit_enable to 1
> to turn it on, but it won't JIT anything, which is contrary
> to the expectation.
>
> This should rather be a hard dependency in the Kconfig, if
> I got it correctly, expressed as e.g.
>
>         select HAVE_EBPF_JIT if !CPU_ENDIAN_BE32

Will do it. That's a good catch. Thanks Daniel.
