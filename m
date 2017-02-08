From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 1/5] bpf: Add missing header to the library
Date: Wed, 8 Feb 2017 10:52:01 +0800
Message-ID: <c83cb57a-c997-3785-b763-a63b4b7114d4@huawei.com>
References: <20170206204027.29078-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206204027.29078-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please add me into the cc list of all of the 5 patches.

Thank you.

On 2017/2/7 4:40, Mickaël Salaün wrote:
> Include stddef.h to define size_t.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Wang Nan <wangnan0@huawei.com>
> ---
>   tools/lib/bpf/bpf.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
> index a2f9853dd882..df6e186da788 100644
> --- a/tools/lib/bpf/bpf.h
> +++ b/tools/lib/bpf/bpf.h
> @@ -22,6 +22,7 @@
>   #define __BPF_BPF_H
>   
>   #include <linux/bpf.h>
> +#include <stddef.h>
>   
>   int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
>   		   int max_entries, __u32 map_flags);
