From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 0/7] Reuse libbpf from samples/bpf
Date: Fri, 9 Dec 2016 12:09:07 -0300
Message-ID: <20161209150907.GM8257@kernel.org>
References: <20161209024620.31660-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161209024620.31660-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Dec 08, 2016 at 06:46:13PM -0800, Joe Stringer escreveu:
> (Was "libbpf: Synchronize implementations")
> 
> Update tools/lib/bpf to provide the remaining bpf wrapper pieces needed by the
> samples/bpf/ code, then get rid of all of the duplicate BPF libraries in
> samples/bpf/libbpf.[ch].
> 
> ---
> v3: Add ack for first patch.
>     Split out second patch from v2 into separate changes for remaining diff.
>     Add patches to switch samples/bpf over to using tools/lib/.
> v2: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
>     Don't shift non-bpf code into libbpf.
>     Drop the patch to synchronize ELF definitions with tc.
> v1: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
>     First post.

Thanks, applied after addressing the -I$(objtree) issue raised by Wang,

- Arnaldo
