From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] tools lib bpf: improve warning
Date: Sun, 20 Aug 2017 17:44:38 -0700
Message-ID: <20170821004436.uygqfpkc6wgdmqmt@ast-mbp>
References: <20170820194814.13785-1-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Wangnan <wangnan0@huawei.com>
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34698 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753427AbdHUAoj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 20:44:39 -0400
Received: by mail-pg0-f68.google.com with SMTP id i12so5942989pgr.1
        for <netdev@vger.kernel.org>; Sun, 20 Aug 2017 17:44:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170820194814.13785-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 20, 2017 at 09:48:14PM +0200, Eric Leblond wrote:
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>  tools/lib/bpf/libbpf.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 1cc3ea0ffdc3..35f6dfcdc565 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -879,7 +879,8 @@ bpf_object__create_maps(struct bpf_object *obj)
>  			size_t j;
>  			int err = *pfd;
>  
> -			pr_warning("failed to create map: %s\n",
> +			pr_warning("failed to create map (name: '%s'): %s\n",
> +				   obj->maps[i].name,
>  				   strerror(errno));

makes sense.
Acked-by: Alexei Starovoitov <ast@kernel.org>
Please cc Wang for future libbpf patches.
