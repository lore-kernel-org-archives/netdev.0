From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/6] bpf: perf_event progs should only use preallocated
 maps
Date: Tue, 30 Aug 2016 02:30:24 +0200
Message-ID: <57C4D3A0.7090100@iogearbox.net>
References: <1472265084-1767670-1-git-send-email-ast@fb.com> <1472265084-1767670-4-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37156 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754167AbcH3Aae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 20:30:34 -0400
In-Reply-To: <1472265084-1767670-4-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2016 04:31 AM, Alexei Starovoitov wrote:
> Make sure that BPF_PROG_TYPE_PERF_EVENT programs only use
> preallocated hash maps, since doing memory allocation
> in overflow_handler can crash depending on where nmi got triggered.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
