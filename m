From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 3/3] bpf: do not test for PCPU_MIN_UNIT_SIZE before
 percpu allocations
Date: Tue, 17 Oct 2017 09:29:26 -0700
Message-ID: <6067d705-dcc4-931a-a379-22311bbf0ee5@gmail.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
 <a11e92b8ba4f5270437caa629307c300bca37976.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, ast@kernel.org, mark.rutland@arm.com,
        richard@nod.at, sp3485@columbia.edu, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a11e92b8ba4f5270437caa629307c300bca37976.1508251210.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2017 07:55 AM, Daniel Borkmann wrote:
> PCPU_MIN_UNIT_SIZE is an implementation detail of the percpu
> allocator. Given we support __GFP_NOWARN now, lets just let
> the allocation request fail naturally instead. The two call
> sites from BPF mistakenly assumed __GFP_NOWARN would work, so
> no changes needed to their actual __alloc_percpu_gfp() calls
> which use the flag already.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

Nice cleanup. Thanks!

Acked-by: John Fastabend <john.fastabend@gmail.com>
