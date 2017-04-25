From: David Miller <davem@davemloft.net>
Subject: llvm-objdump...
Date: Tue, 25 Apr 2017 13:13:37 -0400 (EDT)
Message-ID: <20170425.131337.2175176102097155053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432408AbdDYRNs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think there are some endianness issues ;-)

davem@patience:~/src/GIT/net-next/tools/testing/selftests/bpf$ llvm-objdump -S x.o

x.o:    file format ELF64-BPF

Disassembly of section test1:
process:
       0:       b7 00 00 00 00 00 00 02         r0 = 33554432
       1:       61 21 00 50 00 00 00 00         r1 = *(u32 *)(r2 + 20480)

That first instruction should be "r0 = 2"
