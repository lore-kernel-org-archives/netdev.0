From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] tools: bpf_jit_disasm: ignore image address
 for disasm
Date: Fri, 16 May 2014 11:34:58 +0200
Message-ID: <5375DBC2.4040307@redhat.com>
References: <1400194599-5247-1-git-send-email-ast@plumgrid.com> <1400194599-5247-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47600 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191AbaEPJfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 05:35:03 -0400
In-Reply-To: <1400194599-5247-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2014 12:56 AM, Alexei Starovoitov wrote:
> seccomp filters use kernel JIT image addresses, so bpf_jit_enable=2 prints
> [ 20.146438] flen=3 proglen=82 pass=0 image=0000000000000000
> [ 20.146442] JIT code: 00000000: 55 48 89 e5 48 81 ec 28 02 00 00 ...
>
> ignore image address, so that seccomp filters can be disassembled
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Looks good to me! Thanks for using bpf_jit_disasm, hope it was of
great help. ;)

Acked-by: Daniel Borkmann <dborkman@redhat.com>
