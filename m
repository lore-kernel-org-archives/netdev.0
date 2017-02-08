From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v3 1/5] bpf: Add missing header to the library
Date: Wed, 8 Feb 2017 17:40:33 -0200
Message-ID: <20170208194033.GA2162@redhat.com>
References: <20170207205609.8035-1-mic@digikod.net>
 <20170207205609.8035-2-mic@digikod.net>
 <b3db796c-b4a5-ffb4-4dc7-4bb28fc1fd00@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b3db796c-b4a5-ffb4-4dc7-4bb28fc1fd00@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Feb 08, 2017 at 10:47:18AM +0800, Wangnan (F) escreveu:
> >+++ b/tools/lib/bpf/bpf.h
> >@@ -22,6 +22,7 @@
> >  #define __BPF_BPF_H
> >  #include <linux/bpf.h>
> >+#include <stddef.h>
> >  int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
> >  		   int max_entries, __u32 map_flags);
> Looks good to me.
> 
> Thank you.

Applied, took the "Thank you" as an "Acked-by: Wang",

Regards,

- Arnaldo
