From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next] bpf: add support for %s specifier to
 bpf_trace_printk()
Date: Thu, 27 Aug 2015 19:43:32 -0400
Message-ID: <20150827194332.279edaa4@gandalf.local.home>
References: <1440656819-25622-1-git-send-email-ast@plumgrid.com>
	<20150827.153409.893765406170260565.davem@davemloft.net>
	<55DF97E6.9050108@plumgrid.com>
	<20150827.162039.1520656052011605652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, mingo@kernel.org, wangnan0@huawei.com,
	hekuang@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150827.162039.1520656052011605652.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Aug 2015 16:20:39 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Thu, 27 Aug 2015 16:06:14 -0700
> 
> > Fair or you still think it should be per byte copy?
> 
> I'm terribly surprised we don't have an equivalent of strncpy()
> for unsafe kernel pointers.
> 
> You probably won't be the last person to want this, and it's silly
> to optimize it in one place and then wait for cut&paste into the
> next guy.

If it doesn't exist. Perhaps its time to create it.

-- Steve
