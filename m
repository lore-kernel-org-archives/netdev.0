From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: filter: rename 'struct
 sock_filter_int' into 'struct bpf_insn'
Date: Thu, 24 Jul 2014 23:27:31 -0700 (PDT)
Message-ID: <20140724.232731.311277115312586882.davem@davemloft.net>
References: <1406245101-21262-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406245101-21262-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 24 Jul 2014 16:38:21 -0700

> eBPF is used by socket filtering, seccomp and soon by tracing and
> exposed to userspace, therefore 'sock_filter_int' name is not accurate.
> Rename it to 'bpf_insn'
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v1->v2: fix alignment of \ in macros (caught by Daniel. thanks!)

Applied, thanks.
