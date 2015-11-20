From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH 4/7] netprio_cgroup: limit the maximum css->id to
 USHRT_MAX
Date: Fri, 20 Nov 2015 10:18:14 +0100
Message-ID: <564EE556.5070907@bmw-carit.de>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <1447959171-20749-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<coreteam@netfilter.org>, <cgroups@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
	<daniel@iogearbox.net>, <nhorman@tuxdriver.com>
To: Tejun Heo <tj@kernel.org>, <davem@davemloft.net>,
	<pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <lizefan@huawei.com>,
	<hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447959171-20749-5-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2015 07:52 PM, Tejun Heo wrote:
> netprio builds per-netdev contiguous priomap array which is indexed by
> css->id.  The array is allocated using kzalloc() effectively limiting
> the maximum ID supported to some thousand range.  This patch caps the
> maximum supported css->id to USHRT_MAX which should be way above what
> is actually useable.
> 
> This allows reducing sock->sk_cgrp_prioidx to u16 from u32.  The freed
> up part will be used to overload the cgroup related fields.
> sock->sk_cgrp_prioidx's position is swapped with sk_mark so that the
> two cgroup related fields are adjacent.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>

Acked-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
