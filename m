From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Tue, 14 Mar 2017 15:49:47 -0700
Message-ID: <20170314224946.GA11983@ast-mbp.thefacebook.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>
To: David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35201 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdCNWtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 18:49:53 -0400
Content-Disposition: inline
In-Reply-To: <20170314212144.29988-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 02:21:39PM -0700, David Daney wrote:
> Changes from v1:
> 
>   - Use unsigned access for SKF_AD_HATYPE
> 
>   - Added three more patches for other problems found.
> 
> 
> Testing the BPF JIT on Cavium OCTEON (mips64) with the test-bpf module
> identified some failures and unimplemented features.
> 
> With this patch set we get:
> 
>      test_bpf: Summary: 305 PASSED, 0 FAILED, [85/297 JIT'ed]
> 
> Both big and little endian tested.
> 
> We still lack eBPF support, but this is better than nothing.
> 
> David Daney (5):
>   MIPS: uasm:  Add support for LHU.
>   MIPS: BPF: Add JIT support for SKF_AD_HATYPE.
>   MIPS: BPF: Use unsigned access for unsigned SKB fields.
>   MIPS: BPF: Quit clobbering callee saved registers in JIT code.
>   MIPS: BPF: Fix multiple problems in JIT skb access helpers.

Thanks. Nice set of fixes. Especially patch 4.
Did you see crashes because of it?
Acked-by: Alexei Starovoitov <ast@kernel.org>
