From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] samples/bpf: fix include path
Date: Tue, 29 Nov 2016 07:34:47 +0100
Message-ID: <583D2187.7060405@iogearbox.net>
References: <1480399642-2475887-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39109 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbcK2Gev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:34:51 -0500
In-Reply-To: <1480399642-2475887-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 07:07 AM, Alexei Starovoitov wrote:
> Fix the following build error:
> HOSTCC  samples/bpf/test_lru_dist.o
> ../samples/bpf/test_lru_dist.c:25:22: fatal error: bpf_util.h: No such file or directory
>
> This is due to objtree != srctree.
> Use srctree, since that's where bpf_util.h is located.
>
> Fixes: e00c7b216f34 ("bpf: fix multiple issues in selftest suite and samples")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Didn't run into this so far, thanks for fixing!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
