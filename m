From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Fri, 05 May 2017 14:53:21 -0400 (EDT)
Message-ID: <20170505.145321.1378827304293216895.davem@davemloft.net>
References: <20170430.120750.651845251226226775.davem@davemloft.net>
        <33505cff-f730-ebac-c2d7-38f1793062b7@fb.com>
        <bf3b6bde-d159-c6a3-a532-83cccb1833d9@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org, yhs@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752199AbdEESxX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 14:53:23 -0400
In-Reply-To: <bf3b6bde-d159-c6a3-a532-83cccb1833d9@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 5 May 2017 11:24:19 -0700

> Yonghong fixed llvm bug with big-endian dwarf [1]
> and binutils worked out of the box :)
> 
> $ ./bin/clang -O2 -target bpfeb -c -g test.c
> $ /w/binutils-gdb/bld/binutils/objdump -S test.o
> 
> test.o:     file format elf64-bpfbe
> 
> Disassembly of section .text:
> 0000000000000000 <bpf_prog1>:
> int bpf_prog1(void *ign)
> {
>   volatile unsigned long t = 0x8983984739ull;
 ...
> [1]
> https://reviews.llvm.org/rL302265

Great, that's good to know!
