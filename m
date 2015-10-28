From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [RFC PATCH net-next 0/4] perf tools: Support receiving output
 through BPF programs
Date: Wed, 28 Oct 2015 19:03:00 +0800
Message-ID: <5630AB64.8080601@huawei.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lizefan@huawei.com>, <pi3orama@163.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <acme@kernel.org>, <ast@kernel.org>, <brendan.d.gregg@gmail.com>,
	<jolsa@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/28 18:55, Wang Nan wrote:
> Alexei provided a patchset to allow BPF programs output data to ring
> buffer using helper bpf_perf_event_output() [1].  and have been merged
> into net-next as commit a43eec304259a6c637f4014a6d4767159b6a3aa3 (bpf:
> introduce bpf_perf_event_output() helper).
>
> This patchset introduces perf side code to utilize that helper,
>
> This patchset only supports output data to CTF. It is enough for me
> because my workflow is 'perf record' -> 'convert to CTF' -> 'python'.
> However, I know some people heavily rely on 'perf script' to parse
> trace in perf.data. Here I'd like discuss the way to show output data
> using 'perf script'. Currently the only way to watch the output data
> using perf script is to use '-D'.
>
> [1] http://lkml.kernel.org/r/1445396556-4854-1-git-send-email-ast@kernel.org

This patchset is based on my perf ebpf support patches. Workable
code can be found from github:

https://github.com/WangNan0/linux/commits/ebpf

It should be merged after net-next merged into mainline. I post
them now for demostration and discussion.

Thank you.
