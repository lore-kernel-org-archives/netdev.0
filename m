From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 1/4] bpf: Make the bpf_prog_array_map more generic
Date: Fri, 31 Jul 2015 09:36:36 -0700
Message-ID: <55BBA414.7040106@plumgrid.com>
References: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
 <1438343970-11974-2-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438343970-11974-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/31/15 4:59 AM, Kaixu Xia wrote:
> According to the comments from Daniel, rewrite part of
> the bpf_prog_array map code and make it more generic.
> So the new perf_event_array map type can reuse most of
> code with bpf_prog_array map and add fewer lines of
> special code.
>
> Tested the samples/bpf/tracex5 after this patch:
> 	$ sudo ./tracex5
> 	...
> 	dd-1051  [000] d...    26.682903: : mmap
> 	dd-1051  [000] d...    26.698348: : syscall=102 (one of get/set uid/pid/gid)
> 	dd-1051  [000] d...    26.703892: : read(fd=0, buf=000000000078c010, size=512)
> 	dd-1051  [000] d...    26.705847: : write(fd=1, buf=000000000078c010, size=512)
> 	dd-1051  [000] d...    26.707914: : read(fd=0, buf=000000000078c010, size=512)
> 	dd-1051  [000] d...    26.710988: : write(fd=1, buf=000000000078c010, size=512)
> 	dd-1051  [000] d...    26.711865: : read(fd=0, buf=000000000078c010, size=512)
> 	dd-1051  [000] d...    26.712704: : write(fd=1, buf=000000000078c010, size=512)
> 	...

the commit log doesn't really need these test results.
Also first paragraph is meaningless without prior history.
Please reword it, so it clearly says what this patch is doing and why.
Anyone reading it years later should be able to understand.
