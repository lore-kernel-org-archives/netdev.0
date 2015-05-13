From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test_bpf: add tests related to BPF_MAXINSNS
Date: Wed, 13 May 2015 13:36:29 -0700
Message-ID: <5553B5CD.6050106@plumgrid.com>
References: <f35ca0ee7ba9a7a934dc6131a32fafa941d8dcad.1431515140.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33352 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965275AbbEMUgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 16:36:31 -0400
Received: by pdbnk13 with SMTP id nk13so62303434pdb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 13:36:30 -0700 (PDT)
In-Reply-To: <f35ca0ee7ba9a7a934dc6131a32fafa941d8dcad.1431515140.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/15 4:12 AM, Daniel Borkmann wrote:
> Couple of torture test cases related to the bug fixed in 0b59d8806a31
> ("ARM: net: delegate filter to kernel interpreter when imm_offset()
> return value can't fit into 12bits.").
>
> I've added a helper to allocate and fill the insn space. Output on
> x86_64 from my laptop:
>
> test_bpf: #233 BPF_MAXINSNS: Maximum possible literals jited:0 7 PASS
> test_bpf: #234 BPF_MAXINSNS: Single literal jited:0 8 PASS
> test_bpf: #235 BPF_MAXINSNS: Run/add until end jited:0 11553 PASS
> test_bpf: #236 BPF_MAXINSNS: Too many instructions PASS
> test_bpf: #237 BPF_MAXINSNS: Very long jump jited:0 9 PASS
> test_bpf: #238 BPF_MAXINSNS: Ctx heavy transformations jited:0 20329 20398 PASS
> test_bpf: #239 BPF_MAXINSNS: Call heavy transformations jited:0 32178 32475 PASS
> test_bpf: #240 BPF_MAXINSNS: Jump heavy test jited:0 10518 PASS
>
> test_bpf: #233 BPF_MAXINSNS: Maximum possible literals jited:1 4 PASS
> test_bpf: #234 BPF_MAXINSNS: Single literal jited:1 4 PASS
> test_bpf: #235 BPF_MAXINSNS: Run/add until end jited:1 1625 PASS
> test_bpf: #236 BPF_MAXINSNS: Too many instructions PASS
> test_bpf: #237 BPF_MAXINSNS: Very long jump jited:1 8 PASS
> test_bpf: #238 BPF_MAXINSNS: Ctx heavy transformations jited:1 3301 3174 PASS
> test_bpf: #239 BPF_MAXINSNS: Call heavy transformations jited:1 24107 23491 PASS
> test_bpf: #240 BPF_MAXINSNS: Jump heavy test jited:1 8651 PASS
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Nicolas Schichan <nschichan@freebox.fr>

Nice tests!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
