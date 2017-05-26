From: David Miller <davem@davemloft.net>
Subject: Re: please revert. Was: [for-next 4/6] net/mlx5: FPGA, Add basic
 support for Innova
Date: Fri, 26 May 2017 00:13:27 -0400 (EDT)
Message-ID: <20170526.001327.1776674102154218120.davem@davemloft.net>
References: <20170523114404.20387-1-saeedm@mellanox.com>
        <20170523114404.20387-5-saeedm@mellanox.com>
        <20170526035830.mrnmxosh262bwjcr@ast-mbp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbdEZENa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 00:13:30 -0400
In-Reply-To: <20170526035830.mrnmxosh262bwjcr@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Thu, 25 May 2017 20:58:32 -0700

> Dave, please revert this Innova fpga stuff.
> I think you pushed it by accident, since it was mixed with
> other valid changes.
> The discussion didn't conclude.
> Myself and Jes are clearly against such changes.
> It definitely needs more discussion and wider consensus.

Why don't you finish your discussion, then I can revert or leave it in
there?

If someone puts an FPGA inside of a device, and it's still behind the
PCI ID of the ethernet card, how they expose that thing is largely at
the discression of the driver author.

So feel free to discuss things with them, but in the end unless I am
convinced otherwise (and I'm currently not), what they are doing now
is fine by me.

I will also state that it can't be that every time Mellanox tries to
add something significant to their driver everyone screams "oh my,
this thing is so hard to maintain as it is, you can't add this feature
_too_."

Sorry, it's an important driver, it's big, it has a lot of features,
and all those problems people talk about simply come with the
territory.

This FPGA thing is just a drop in the bucket as far as long term
maintainence and backporting is concerned, so if that truly is the
basis of why you are against these changes, there is not much weight
to that argument.

Use a less featurefull device, which uses a driver with slower
development and less changes, if these things truly bother you.

Thanks.
