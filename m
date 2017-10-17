From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 3/3] bpf: do not test for PCPU_MIN_UNIT_SIZE before
 percpu allocations
Date: Tue, 17 Oct 2017 08:55:09 -0700
Message-ID: <20171017155507.d7i6bzwnfchtztws@ast-mbp.dhcp.thefacebook.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
 <a11e92b8ba4f5270437caa629307c300bca37976.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tj@kernel.org, ast@kernel.org,
        john.fastabend@gmail.com, mark.rutland@arm.com, richard@nod.at,
        sp3485@columbia.edu, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a11e92b8ba4f5270437caa629307c300bca37976.1508251210.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 04:55:54PM +0200, Daniel Borkmann wrote:
> PCPU_MIN_UNIT_SIZE is an implementation detail of the percpu
> allocator. Given we support __GFP_NOWARN now, lets just let
> the allocation request fail naturally instead. The two call
> sites from BPF mistakenly assumed __GFP_NOWARN would work, so
> no changes needed to their actual __alloc_percpu_gfp() calls
> which use the flag already.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
