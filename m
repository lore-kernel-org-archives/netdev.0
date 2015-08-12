From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix build warnings and add function
 read_trace_pipe()
Date: Wed, 12 Aug 2015 16:39:26 -0700 (PDT)
Message-ID: <20150812.163926.1443596955889419582.davem@davemloft.net>
References: <1439372273-69958-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@plumgrid.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	wangnan0@huawei.com, pi3orama@163.com
To: xiakaixu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439372273-69958-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kaixu Xia <xiakaixu@huawei.com>
Date: Wed, 12 Aug 2015 09:37:53 +0000

> There are two improvements in this patch:
>  1. Fix the build warnings;
>  2. Add function read_trace_pipe() to print the result on
>     the screen;
> 
> Before this patch, we can get the result through /sys/kernel/de
> bug/tracing/trace_pipe and get nothing on the screen.
> By applying this patch, the result can be printed on the screen.
>   $ ./tracex6
> 	...
>          tracex6-705   [003] d..1   131.428593: : CPU-3   19981414
>             sshd-683   [000] d..1   131.428727: : CPU-0   221682321
>             sshd-683   [000] d..1   131.428821: : CPU-0   221808766
>             sshd-683   [000] d..1   131.428950: : CPU-0   221982984
>             sshd-683   [000] d..1   131.429045: : CPU-0   222111851
>          tracex6-705   [003] d..1   131.429168: : CPU-3   20757551
>             sshd-683   [000] d..1   131.429170: : CPU-0   222281240
>             sshd-683   [000] d..1   131.429261: : CPU-0   222403340
>             sshd-683   [000] d..1   131.429378: : CPU-0   222561024
> 	...
> 
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>

Applied, thanks.
