From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next] net: fix test_bpf build to depend on NET
Date: Tue, 13 May 2014 10:04:23 -0700
Message-ID: <CAADnVQKPRbDjP=G2b0dopYrLzo+r=AkuLed5hDXDJT2HkE92pA@mail.gmail.com>
References: <53724F44.2010608@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <53724F44.2010608@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2014 at 9:58 AM, Randy Dunlap <rdunlap@infradead.org> wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
>
> Fix build when CONFIG_NET is not enabled.
> Fixes these build errors:
>
> WARNING: "sk_unattached_filter_destroy" [lib/test_bpf.ko] undefined!
> WARNING: "kfree_skb" [lib/test_bpf.ko] undefined!
> WARNING: "sk_unattached_filter_create" [lib/test_bpf.ko] undefined!
> WARNING: "sk_run_filter_int_skb" [lib/test_bpf.ko] undefined!
> WARNING: "__alloc_skb" [lib/test_bpf.ko] undefined!
>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

ohh. yes. sorry about that.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> ---
>  lib/Kconfig.debug |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- linux-next-20140513.orig/lib/Kconfig.debug
> +++ linux-next-20140513/lib/Kconfig.debug
> @@ -1639,7 +1639,7 @@ config TEST_USER_COPY
>  config TEST_BPF
>         tristate "Test BPF filter functionality"
>         default n
> -       depends on m
> +       depends on m && NET
>         help
>           This builds the "test_bpf" module that runs various test vectors
>           against the BPF interpreter or BPF JIT compiler depending on the
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
