From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix out of bounds access in verifier log
Date: Tue, 08 Sep 2015 23:00:25 +0200
Message-ID: <55EF4C69.3010401@iogearbox.net>
References: <1441744801-15537-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yonghong Song <yhs@plumgrid.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45526 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbbIHVAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 17:00:30 -0400
In-Reply-To: <1441744801-15537-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2015 10:40 PM, Alexei Starovoitov wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
