From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 22:13:15 -0400 (EDT)
Message-ID: <20170429.221315.1605574480939856975.davem@davemloft.net>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
        <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1164479AbdD3CNR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 22:13:17 -0400
In-Reply-To: <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 17:48:43 -0700

> /w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
> /w/binutils-gdb/bld/binutils/objdump: Dwarf Error: found address size

I discussed this in another email, the relocation numbers I used in
binutils do not match what is in LLVM currently.

In fact, I thought you guys weren't using relocations in any capacity
at all so just picked things from scratch :-)
