From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] bpf: Fix test_obj_id.c for llvm 5.0
Date: Fri, 09 Jun 2017 12:06:53 +0200
Message-ID: <593A733D.2030104@iogearbox.net>
References: <20170609053017.2909855-1-kafai@fb.com> <20170609053017.2909855-2-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, Yonghong Song <yhs@fb.com>,
        kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35286 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbdFIKGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 06:06:55 -0400
In-Reply-To: <20170609053017.2909855-2-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2017 07:30 AM, Martin KaFai Lau wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
