From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: more test_progs...
Date: Tue, 25 Apr 2017 22:49:53 +0200
Message-ID: <58FFB671.9040907@iogearbox.net>
References: <20170425.125217.1962662516948420246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59498 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1954517AbdDYUt6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 16:49:58 -0400
In-Reply-To: <20170425.125217.1962662516948420246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2017 06:52 PM, David Miller wrote:
[...]
> Load eth->h_proto
>
> 10: (15) if r3 == 0xdd86 goto pc+9
>   R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=14) R2=pkt_end R3=inv R4=pkt(id=0,off=14,r=14) R5=inv56 R10=fp
>
> Hmmm, endianness looks wrong here.  "-target bpf" defaults to the
> endianness of whatever cpu that llvm was built for, right?

Hmm, would it show the right endianess when you compile
with "-target bpfeb"?

My understanding is that "-target bpf" defaults to host
cpu's endianess, and since you likely built clang/llvm
directly on sparc, it should also all run on target
endianness anyway (so no potential mixup when compiling
f.e. bpfeb on x86_64).
