From: David Miller <davem@davemloft.net>
Subject: Re: llvm-objdump...
Date: Fri, 28 Apr 2017 12:38:18 -0400 (EDT)
Message-ID: <20170428.123818.2002639536695380745.davem@davemloft.net>
References: <612f0df6-711c-b6b1-4bd7-596a7f329737@fb.com>
        <20170428.121710.1780087759147659481.davem@davemloft.net>
        <c9e9eaa7-0fa8-440a-dc75-2d4020b8c429@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756811AbdD1QiT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:38:19 -0400
In-Reply-To: <c9e9eaa7-0fa8-440a-dc75-2d4020b8c429@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 28 Apr 2017 09:22:32 -0700

> On 4/28/17 9:17 AM, David Miller wrote:
>> Even if I give it -triple=bpfeb it emits immediates incorrectly.
>>
>> The bug is certainly in the insn field fetcher of the disassembler.
> 
> got it. so the binary looks correct, but disasm output is wrong?

F.e.

      12:       07 70 00 00 00 00 00 06         r0 += 100663296

Should be "r0 += 6"

Yes.
