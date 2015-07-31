From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 2/4] bpf: Add new bpf map type to store the pointer to
 struct perf_event
Date: Fri, 31 Jul 2015 09:39:36 -0700
Message-ID: <55BBA4C8.1030805@plumgrid.com>
References: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
 <1438343970-11974-3-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1438343970-11974-3-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/31/15 4:59 AM, Kaixu Xia wrote:
> +	/*
> +	 * prevent some crazy events so we can make our life easier
> +	 */
> +	if (event->attr.type != PERF_TYPE_RAW &&
> +	    event->attr.type != PERF_TYPE_HARDWARE) {
> +		perf_event_release_kernel(event);
> +		return ERR_PTR(-EINVAL);
> +	}

either remove the comment and make it clean.
