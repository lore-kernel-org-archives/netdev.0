From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 08:51:06 -0700
Message-ID: <562905EA.2020101@plumgrid.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
 <562874A5.1050307@huawei.com> <5628807C.3040305@plumgrid.com>
 <562892C8.7030108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562892C8.7030108@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/15 12:39 AM, Wangnan (F) wrote:
>   ...
>   if (!perf_event_can_insert_to_map(attr))
>      ....
>
> Do you think redability is improved?

yes. makes sense. will respin.
