From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v4 0/3] Miscellaneous fixes for BPF (perf tree)
Date: Fri, 10 Feb 2017 15:42:34 -0200
Message-ID: <20170210174234.GH2162@redhat.com>
References: <20170208202744.16274-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: Wang Nan <wangnan0@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753379AbdBJSHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 13:07:54 -0500
Content-Disposition: inline
In-Reply-To: <20170208202744.16274-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Feb 08, 2017 at 09:27:41PM +0100, Mickaël Salaün escreveu:
> This series brings some fixes and small improvements to the BPF samples.
> 
> This is intended for the perf tree and apply on 7a5980f9c006 ("tools lib bpf:
> Add missing header to the library").

Wang, are you ok with this series? Joe?

- Arnaldo
 
> Changes since v3:
> * remove applied patch 1/5
> * remove patch 2/5 on bpf_load_program() as requested by Wang Nan
> 
> Changes since v2:
> * add this cover letter
> 
> Changes since v1:
> * exclude patches not intended for the perf tree
> 
> Regards,
> 
> Mickaël Salaün (3):
>   samples/bpf: Ignore already processed ELF sections
>   samples/bpf: Reset global variables
>   samples/bpf: Add missing header
> 
>  samples/bpf/bpf_load.c     | 7 +++++++
>  samples/bpf/tracex5_kern.c | 1 +
>  2 files changed, 8 insertions(+)
> 
> -- 
> 2.11.0
