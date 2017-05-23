From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: update perf event helper function
 signature and documentation
Date: Mon, 22 May 2017 23:08:49 -0400 (EDT)
Message-ID: <20170522.230849.1056416550811494880.davem@davemloft.net>
References: <E796EF36-C195-4FFA-AAA0-A1F9E7730349@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, bgregg@netflix.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Kernel-team@fb.com, ast@fb.com
To: qinteng@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E796EF36-C195-4FFA-AAA0-A1F9E7730349@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teng Qin <qinteng@fb.com>
Date: Tue, 23 May 2017 00:39:34 +0000

> diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
> index 9a9c95f..a94ce42 100644
> --- a/samples/bpf/bpf_helpers.h
> +++ b/samples/bpf/bpf_helpers.h
> @@ -37,9 +37,8 @@ static int (*bpf_clone_redirect)(void *ctx, int ifindex, int flags) =
>  	(void *) BPF_FUNC_clone_redirect;
>  static int (*bpf_redirect)(int ifindex, int flags) =
>  	(void *) BPF_FUNC_redirect;
> -static int (*bpf_perf_event_output)(void *ctx, void *map,
> -				    unsigned long long flags, void *data,
> -				    int size) =
> +static int (*bpf_perf_event_output)(void *ctx, void *map, u64 flags,
> +	                            void *data, int size) =
>  	(void *) BPF_FUNC_perf_event_output;
>  static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
>  	(void *) BPF_FUNC_get_stackid;

I think we've been intentionally avoiding the use of "u64", "u32",
etc. in this file.

But what do I know.
