From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] support for '%s' in bpf_trace_printk
Date: Fri, 28 Aug 2015 16:27:44 -0700 (PDT)
Message-ID: <20150828.162744.232091866121034954.davem@davemloft.net>
References: <1440802583-5020-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, rostedt@goodmis.org,
	masami.hiramatsu.pt@hitachi.com, wangnan0@huawei.com,
	hekuang@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440802583-5020-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 28 Aug 2015 15:56:21 -0700

> v2->v3:
> fix the comment to mention that strncpy_from_unsafe() returns
> the length of the string including the trailing NUL.
> 
> v1->v2:
> patch 1: generalize FETCH_FUNC_NAME(memory, string) into
> strncpy_from_unsafe()
> patch 2: use it in bpf_trace_printk

Looks good, series applied, thanks Alexei.
