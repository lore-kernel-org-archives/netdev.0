From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] perf/core: Put size of a sample at the end of
 it by PERF_SAMPLE_TAILSIZE
Date: Mon, 11 Jan 2016 10:13:04 -0800
Message-ID: <20160111181303.GA26146@ast-mbp.thefacebook.com>
References: <1452518653-1794-1-git-send-email-wangnan0@huawei.com>
 <5693E0C6.2080509@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, davem@davemloft.net,
	acme@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Yunlong Song <yunlong.song@huawei.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5693E0C6.2080509@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 06:05:10PM +0100, Daniel Borkmann wrote:
> Hi Wang,
> 
> On 01/11/2016 02:24 PM, Wang Nan wrote:
> >This patch introduces a PERF_SAMPLE_TAILSIZE flag which allows a size
> >field attached at the end of a sample. The idea comes from [1] that,
> >with tie size at tail of an event, it is possible for user program who
> >read from the ring buffer parse events backward.
...
> >Signed-off-by: Wang Nan <wangnan0@huawei.com>
> [...]
> 
> As this seems unrelated to networking, net-next tree seems not really appropriate?

clearly not for net-next.
Wang, see my reply to the same patch in your other thread.
