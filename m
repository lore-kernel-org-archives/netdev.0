From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/6] bpf: hash: avoid to call kmalloc() in eBPF prog
Date: Wed, 16 Dec 2015 00:42:47 +0100
Message-ID: <5670A577.3010207@iogearbox.net>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com> <1450178464-27721-6-git-send-email-tom.leiming@gmail.com> <20151215231057.GB67370@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151215231057.GB67370@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/16/2015 12:10 AM, Alexei Starovoitov wrote:
...
> this rounding to cache line is great for performance, but it's extra
> memory upfront which may not be needed. The per-allocation is a classic
> performance vs memory trade-off. In other cases it may hurt.
> So could you change the patch to do pre-allocation only when
> requested by user space via extra flag for hash map or via
> new BPF_MAP_TYPE_HASH_PREALLOC type? Not sure yet whether flag or
> new type is better. I guess implementation will dictate.

Was also thinking about this, probably new map type makes sense.
