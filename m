From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/6] bpf: support 8-byte metafield access
Date: Tue, 30 Aug 2016 01:44:34 +0200
Message-ID: <57C4C8E2.6040903@iogearbox.net>
References: <1472265084-1767670-1-git-send-email-ast@fb.com> <1472265084-1767670-2-git-send-email-ast@fb.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472265084-1767670-2-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/27/2016 04:31 AM, Alexei Starovoitov wrote:
> The verifier supported only 4-byte metafields in
> struct __sk_buff and struct xdp_md. The metafields in upcoming
> struct bpf_perf_event are 8-byte to match register width in struct pt_regs.
> Teach verifier to recognize 8-byte metafield access.
> The patch doesn't affect safety of sockets and xdp programs.
> They check for 4-byte only ctx access before these conditions are hit.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
