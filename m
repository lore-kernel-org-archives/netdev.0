From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Sat, 26 Nov 2016 20:40:19 +0200
Message-ID: <CAKoUArk7JFS-FQfHuGXgY0AhnB_3gij8jkYEVY4v88LQkn6Ugw@mail.gmail.com>
References: <1480145027-3524392-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34833 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbcKZSkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 13:40:20 -0500
Received: by mail-qt0-f194.google.com with SMTP id m48so7235988qta.2
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 10:40:20 -0800 (PST)
In-Reply-To: <1480145027-3524392-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Rami Rosen <roszenrami@gmail.com>

On 26 November 2016 at 09:23, Alexei Starovoitov <ast@fb.com> wrote:
> this #include is unnecessary and brings whole set of
> other headers into cgroup-defs.h. Remove it.
>
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  include/linux/bpf-cgroup.h | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
> index ec80d0c0953e..0cf1adfadd2d 100644
> --- a/include/linux/bpf-cgroup.h
> +++ b/include/linux/bpf-cgroup.h
> @@ -1,7 +1,6 @@
>  #ifndef _BPF_CGROUP_H
>  #define _BPF_CGROUP_H
>
> -#include <linux/bpf.h>
>  #include <linux/jump_label.h>
>  #include <uapi/linux/bpf.h>
>
> --
> 2.8.0
>
