From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: bpf debug info
Date: Tue, 6 Dec 2016 12:12:01 -0300
Message-ID: <20161206151201.GD2399@kernel.org>
References: <20161129064217.GA20124@ast-mbp.thefacebook.com>
 <583D9AA4.8050601@iogearbox.net>
 <20161129170115.GB22217@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, kernel-team@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56962 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752111AbcLFPM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 10:12:28 -0500
Content-Disposition: inline
In-Reply-To: <20161129170115.GB22217@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Nov 29, 2016 at 09:01:17AM -0800, Alexei Starovoitov escreveu:
> On Tue, Nov 29, 2016 at 04:11:32PM +0100, Daniel Borkmann wrote:
> > On 11/29/2016 07:42 AM, Alexei Starovoitov wrote:
> > >Notice that 'clang -S -o a.s' output and llvm-objdump disassembler
> > >were changed to use kernel verifier style, so now it should be easier
> > >to see what's going on.

> > Sounds really useful, is that scheduled for llvm 3.10 release?

> llvm 4.0 :)

> > That debugging info is stored in dwarf format into the obj, right?

> right.

> > Would be nice if also pahole could work on bpf object files.
> 
> yeah. pahole need to be taught to recognize bpf e_machine type and relocations.

Coincidentally I'm testing some perf patches wrt builtin BPF and for
that I'm updating to llvm to 4.0, will take a look at what is involved
in that...

- Arnaldo
