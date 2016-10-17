From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 6/8] tools lib bpf: improve warning
Date: Mon, 17 Oct 2016 10:17:13 +0800
Message-ID: <580434A9.7020104@huawei.com>
References: <20161016211834.11732-1-eric@regit.org>
 <20161016211834.11732-7-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161016211834.11732-7-eric@regit.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/10/17 5:18, Eric Leblond wrote:
> Signed-off-by: Eric Leblond <eric@regit.org>

Please add some commit messages.

Thank you.

> ---
>   tools/lib/bpf/libbpf.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 7cd341e..1fe4532 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -802,7 +802,8 @@ bpf_object__create_maps(struct bpf_object *obj)
>   			size_t j;
>   			int err = *pfd;
>   
> -			pr_warning("failed to create map: %s\n",
> +			pr_warning("failed to create map (name: '%s'): %s\n",
> +				   obj->maps[i].name,
>   				   strerror(errno));
>   			for (j = 0; j < i; j++)
>   				zclose(obj->maps[j].fd);
