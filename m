From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Sat, 21 Nov 2015 21:26:25 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1511212125400.24812@nerf40.vanv.qr>
References: <1448122441-9335-1-git-send-email-tj@kernel.org> <1448122441-9335-10-git-send-email-tj@kernel.org> <20151121165605.GC25336@breakpoint.cc> <20151121170425.GD3428@htj.duckdns.org> <20151121185419.GD25336@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Tejun Heo <tj@kernel.org>, davem@davemloft.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.co, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com,
	Neil Horman <nhorman@tuxdriver.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151121185419.GD25336@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2015-11-21 19:54, Florian Westphal wrote:
>
>The only other question I have is wheter PATH_MAX might be a possible
>ABI breaker in future.  It would have to be guaranteed that this is the
>same size forever, else you'd get strange errors on rule insertion if
>the sizes of the kernel and userspace version differs.
>
The same goes for IFNAMSIZ. But, so far, nobody changed it in the kernel,
even though there are voices that 15 characters + '\0' were a tight choice.
