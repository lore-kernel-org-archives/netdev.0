From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bpf: Fix test_obj_id.c for llvm 5.0
Date: Fri, 09 Jun 2017 15:15:50 -0400 (EDT)
Message-ID: <20170609.151550.1632715464840609277.davem@davemloft.net>
References: <20170609053017.2909855-1-kafai@fb.com>
        <20170609053017.2909855-2-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        yhs@fb.com, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdFITPw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:15:52 -0400
In-Reply-To: <20170609053017.2909855-2-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 8 Jun 2017 22:30:17 -0700

> llvm 5.0 does not like the section name and the function name
> to be the same:
> 
> clang -I. -I./include/uapi -I../../../include/uapi \
> 	-I../../../../samples/bpf/ \
> 	-Wno-compare-distinct-pointer-types \
> 	-O2 -target bpf -c \
> 	linux/tools/testing/selftests/bpf/test_obj_id.c -o \
> 	linux/tools/testing/selftests/bpf/test_obj_id.o
> fatal error: error in backend: 'test_prog_id' label emitted multiple times to
> assembly file
> clang-5.0: error: clang frontend command failed with exit code 70 (use -v to
> see invocation)
> clang version 5.0.0 (trunk 304326) (llvm/trunk 304329)
> 
> This patch makes changes to the section name and the function name.
> 
> Fixes: 95b9afd3987f ("bpf: Test for bpf ID")
> Reported-by: Alexei Starovoitov <ast@fb.com>
> Reported-by: Yonghong Song <yhs@fb.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied.
