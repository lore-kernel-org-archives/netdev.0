From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH][net-next] Documentation: replace __sk_run_filter with __bpf_prog_run
Date: Thu, 9 Oct 2014 21:20:04 -0700
Message-ID: <CAADnVQLOV3_QXQXnkUkQ+JNoudEwmLS37iwiEHxJwFWVOJqJxQ@mail.gmail.com>
References: <1412912214-964-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com, Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:57276 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaJJEUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:20:06 -0400
Received: by mail-qg0-f45.google.com with SMTP id q107so3386499qgd.18
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 21:20:04 -0700 (PDT)
In-Reply-To: <1412912214-964-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 8:36 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> __sk_run_filter has been renamed as __bpf_prog_run, so replace them in comments
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> ---
>  Documentation/networking/filter.txt |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
> index 5ce4d07..c22b797 100644
> --- a/Documentation/networking/filter.txt
> +++ b/Documentation/networking/filter.txt
> @@ -700,11 +700,11 @@ Some core changes of the new internal format:
>      bpf_exit
>
>    If f2 is JITed and the pointer stored to '_f2'. The calls f1 -> f2 -> f3 and
> -  returns will be seamless. Without JIT, __sk_run_filter() interpreter needs to
> +  returns will be seamless. Without JIT, __bpf_prog_run() interpreter needs to
>    be used to call into f2.
>
>    For practical reasons all eBPF programs have only one argument 'ctx' which is
> -  already placed into R1 (e.g. on __sk_run_filter() startup) and the programs
> +  already placed into R1 (e.g. on __bpf_prog_run() startup) and the programs
>    can call kernel functions with up to 5 arguments. Calls with 6 or more arguments
>    are currently not supported, but these restrictions can be lifted if necessary
>    in the future.
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
