From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Wed, 3 Jul 2013 00:36:35 +0300
Message-ID: <CAJZOPZ+1JKs-rK3kig64qgahVoYenkCR47JM3f4T6LEfhLqPhQ@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	<CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	<CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	<CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eli Cohen <eli@dev.mellanox.co.il>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:61369 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890Ab3GBVgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 17:36:37 -0400
In-Reply-To: <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 8:49 PM, Roland Dreier <roland@kernel.org> wrote:
> So I'm inclined to apply the mlx5 driver for 3.11, since it's a
> completely new driver.  However, reading through it so far I had the
> following comments, and I'd like these cleanups addressed along with Dave Miller's:

Roland,

Working to have all Dave Miller's comments addressed along with yours
and post V2 later this week, so we will be still on track for a 3.11
merge of the core and IB driver through your tree.


> - The debug mask complexity seems unnecessary now that pr_debug() is
> controllable at runtime with the DYNAMIC_DEBUG stuff.  We should get
> rid of the extra level of indirection.

OK

> - I think the active flag for the health check timer is unnecessary.
> It can just be stopped with del_timer_sync().

Jack was looking on this today and we're not sure, he will send his
reading of the matter tomorrow.

> - Many places use "foo_spl" as a name, and in the Linux kernel
> "foo_lock" would be much more idiomatic and easier to read.

sure, done.

>
> - In:
>
> +struct mlx5_cmd {
> ...
> +    struct mlx5_cmd_stats    stats[0x80a];
>
> the 0x80a magic number really needs to have a name.

done.
