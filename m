From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: please revert. Was: [for-next 4/6] net/mlx5: FPGA, Add basic
 support for Innova
Date: Fri, 26 May 2017 10:51:18 -0400 (EDT)
Message-ID: <20170526.105118.1248551991513045375.davem@davemloft.net>
References: <20170526035830.mrnmxosh262bwjcr@ast-mbp>
        <20170526.001327.1776674102154218120.davem@davemloft.net>
        <20170526044057.qpk3stulth5tfxcx@ast-mbp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170526044057.qpk3stulth5tfxcx@ast-mbp>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 25 May 2017 21:40:59 -0700

> On Fri, May 26, 2017 at 12:13:27AM -0400, David Miller wrote:
>> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Thu, 25 May 2017 20:58:32 -0700
>> 
>> > Dave, please revert this Innova fpga stuff.
>> > I think you pushed it by accident, since it was mixed with
>> > other valid changes.
>> > The discussion didn't conclude.
>> > Myself and Jes are clearly against such changes.
>> > It definitely needs more discussion and wider consensus.
>> 
>> Why don't you finish your discussion, then I can revert or leave it in
>> there?
> 
> Not really. What you're saying is 'shut up. mellanox can do
> whatever they like as long as it's hidden behind pcie id'.

No, what I'm saying is, discuss things.

And if in the end you agree with Mellanox, we don't have flapping of
the change in and out of the tree over and over.

My understanding is that this FPGA offloads processing the data
stream, which in a way is not much different than JIT'ing eBPF
onto Netronome cpus. :-)

Maybe the programming interface is different, maybe all the algorithms
are implemented in discrete ASICs, but effect is quite similar.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
