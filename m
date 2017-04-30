From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sun, 30 Apr 2017 11:40:24 -0400 (EDT)
Message-ID: <20170430.114024.1304052185817716163.davem@davemloft.net>
References: <20170429.222450.1300920007783667009.davem@davemloft.net>
        <20170429.223759.1262491011130998405.davem@davemloft.net>
        <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdD3Pk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 11:40:26 -0400
In-Reply-To: <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 23:44:59 -0700

> On 4/29/17 7:37 PM, David Miller wrote:
>> BTW, should I just remove tailcall from the opcode table altogether?
> 
> yeah. tailcall is not a special opcode from user space point of view.
> Only after normal call with func_id=bpf_tail_call passes verifier
> then verifier will change insn->code into CALL|X
> It's done only to have two 'case' statement in the interpreter,
> so that normal calls and tailcalls don't interfere.
> From user space pov CALL|X opcode is reserved and we can use it
> for something in the future. Just need to change interpeter and JITs.

Ok, I've removed it from my tree.

Thanks.
