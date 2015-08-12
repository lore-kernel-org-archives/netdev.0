From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: fix build warnings and add function
 read_trace_pipe()
Date: Wed, 12 Aug 2015 09:25:54 -0700
Message-ID: <55CB7392.4070701@plumgrid.com>
References: <1439372273-69958-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	wangnan0@huawei.com, pi3orama@163.com
To: Kaixu Xia <xiakaixu@huawei.com>, daniel@iogearbox.net,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439372273-69958-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/12/15 2:37 AM, Kaixu Xia wrote:
> There are two improvements in this patch:
>   1. Fix the build warnings;
>   2. Add function read_trace_pipe() to print the result on
>      the screen;
>
> Before this patch, we can get the result through /sys/kernel/de
> bug/tracing/trace_pipe and get nothing on the screen.
> By applying this patch, the result can be printed on the screen.
>    $ ./tracex6
> 	...
>           tracex6-705   [003] d..1   131.428593: : CPU-3   19981414
>              sshd-683   [000] d..1   131.428727: : CPU-0   221682321
>              sshd-683   [000] d..1   131.428821: : CPU-0   221808766
>              sshd-683   [000] d..1   131.428950: : CPU-0   221982984
>              sshd-683   [000] d..1   131.429045: : CPU-0   222111851
>           tracex6-705   [003] d..1   131.429168: : CPU-3   20757551
>              sshd-683   [000] d..1   131.429170: : CPU-0   222281240
>              sshd-683   [000] d..1   131.429261: : CPU-0   222403340
>              sshd-683   [000] d..1   131.429378: : CPU-0   222561024
> 	...
>
> Signed-off-by: Kaixu Xia<xiakaixu@huawei.com>

thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
