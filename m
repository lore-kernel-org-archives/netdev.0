From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tools/net/Makefile: Define PACKAGE to fix build
 problems
Date: Wed, 12 Mar 2014 00:08:33 -0400 (EDT)
Message-ID: <20140312.000833.1949958699048857702.davem@davemloft.net>
References: <1394447988-31299-1-git-send-email-markos.chandras@imgtec.com>
	<1394527779-6995-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dborkman@redhat.com,
	netdev@vger.kernel.org
To: markos.chandras@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394527779-6995-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markos Chandras <markos.chandras@imgtec.com>
Date: Tue, 11 Mar 2014 08:49:39 +0000

> Fixes the following build problem with binutils-2.24
> 
> gcc -Wall -O2   -c -o bpf_jit_disasm.o bpf_jit_disasm.c
> In file included from bpf_jit_disasm.c:25:0:
> /usr/include/bfd.h:35:2: error: #error config.h must be included
> before this header
>  #error config.h must be included before this header
> 
> This is similar to commit 3ce711a6abc27abce1554e1d671a8762b7187690
> "perf tools: bfd.h/libbfd detection fails with recent binutils"
> 
> See: https://sourceware.org/bugzilla/show_bug.cgi?id=14243
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: Daniel Borkmann <dborkman@redhat.com>
> CC: netdev@vger.kernel.org
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>

Applied, thank you.
