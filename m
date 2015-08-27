From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add support for %s specifier to
 bpf_trace_printk()
Date: Thu, 27 Aug 2015 16:20:39 -0700 (PDT)
Message-ID: <20150827.162039.1520656052011605652.davem@davemloft.net>
References: <1440656819-25622-1-git-send-email-ast@plumgrid.com>
	<20150827.153409.893765406170260565.davem@davemloft.net>
	<55DF97E6.9050108@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, rostedt@goodmis.org, wangnan0@huawei.com,
	hekuang@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55DF97E6.9050108@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 27 Aug 2015 16:06:14 -0700

> Fair or you still think it should be per byte copy?

I'm terribly surprised we don't have an equivalent of strncpy()
for unsafe kernel pointers.

You probably won't be the last person to want this, and it's silly
to optimize it in one place and then wait for cut&paste into the
next guy.
