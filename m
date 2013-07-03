From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Wed, 3 Jul 2013 23:25:11 +0300
Message-ID: <CAJZOPZJLSTaTwp7EBE2OLCpnWZTyEsUF84X0aw9XEzTFN-fW+A@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	<CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	<CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	<CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
	<51D45449.5010604@mellanox.com>
	<CAL1RGDU0JiGPFEAu87JbxxbHWbgZVsRz1qbz4BvqbCJU9RtRAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:44955 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932988Ab3GCUZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 16:25:12 -0400
In-Reply-To: <CAL1RGDU0JiGPFEAu87JbxxbHWbgZVsRz1qbz4BvqbCJU9RtRAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 3, 2013 at 10:26 PM, Roland Dreier <roland@kernel.org> wrote:
> On Wed, Jul 3, 2013 at 9:41 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> > Jack looked on this comment/code and he says that the active flag is used
> > to prevent re-scheduling the timer from inside the timer handling routine.
> >
> > In the kernel, the comment header in the source file for del_timer_sync
> > explicitly states that re-scheduling the timer must be prevented,
> > or the sync is useless:Callers must prevent restarting of the timer,
> > otherwise
> > this function is meaningless
> >
> > So we believe that code should remain.
>
> Look at the actual timer code.  del_timer_sync() won't work if
> something unrelated re-adds the timer, but it will work if the timer
> itself is what re-adds itself.

[...]

OK, we will re-look into that tomorrow. So how V2 looks?

Or.
