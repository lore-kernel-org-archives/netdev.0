From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix out of bounds access in verifier log
Date: Wed, 09 Sep 2015 14:12:09 -0700 (PDT)
Message-ID: <20150909.141209.1862840660985023052.davem@davemloft.net>
References: <1441744801-15537-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, yhs@plumgrid.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbbIIVMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:12:10 -0400
In-Reply-To: <1441744801-15537-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  8 Sep 2015 13:40:01 -0700

> when the verifier log is enabled the print_bpf_insn() is doing
> bpf_alu_string[BPF_OP(insn->code) >> 4]
> and
> bpf_jmp_string[BPF_OP(insn->code) >> 4]
> where BPF_OP is a 4-bit instruction opcode.
> Malformed insns can cause out of bounds access.
> Fix it by sizing arrays appropriately.
> 
> The bug was found by clang address sanitizer with libfuzzer.
> 
> Reported-by: Yonghong Song <yhs@plumgrid.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
