From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Fri, 21 Apr 2017 15:41:52 -0400 (EDT)
Message-ID: <20170421.154152.510081812790700678.davem@davemloft.net>
References: <20170421184935.GA86324@ast-mbp.thefacebook.com>
        <20170421.150226.825217448288272000.davem@davemloft.net>
        <20170421192619.GA91454@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, sparclinux@vger.kernel.org,
        netdev@vger.kernel.org, ast@kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170421192619.GA91454@ast-mbp.thefacebook.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Fri, 21 Apr 2017 12:26:21 -0700

> It should pick up local headers without touching /usr/include.
> In the past I used to do 'make headers_install' before doing a build
> in samples/bpf or selftests, but then suddenly it started working
> without that step, so I figured something got fixed in the build system.
> May be it's arch specific somehow.

Yes, that's what the issue seemed to be.

I ran something unrelated and that triggered a headers_install, and
after that everything built fine.

I have some minor patches coming, to define arch specific accessors
for bpf_helpers.h and such.
