From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] bpf: bpf_htab: Add
 BPF_MAP_TYPE_PERCPU_HASH
Date: Tue, 12 Jan 2016 16:45:36 -0500 (EST)
Message-ID: <20160112.164536.17755595447757162.davem@davemloft.net>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexei.starovoitov@gmail.com, tom.leiming@gmail.com,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 12 Jan 2016 00:20:48 -0800

> BPF + kprobe is very useful in statistics collection.  In particular,
> bpf is strong in doing aggregation within the kernel instead of
> outputting a lot of raw samples to the userspace.
> 
> In some cases, bumping a counter/value of a particular key will have
> noticeable impact.  For example, doing statistics collection
> on received packets and aggregating them by network
> prefix (like /64 in IPv6).  Having a percpu value can help.

Please:

	http://marc.info/?l=linux-netdev&m=145248145925834&w=2

Thanks.
