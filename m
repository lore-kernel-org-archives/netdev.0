From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: packet re-ordering on SMP machines.
Date: Mon, 16 Sep 2002 01:55:43 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209152155.BAA00855@mops.inr.ac.ru>
References: <20020915104201.D3810@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org (Harald Welte)
In-Reply-To: <20020915104201.D3810@sunbeam.de.gnumonks.org> from "Harald Welte" at Sep 15, 2 10:42:01 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> The iptables ULOG target passes the skb receive timestamp to userspace,

No differences of packet socket.

> one netlink message sent to userspace.  If userspace would make a timestamp,

Nobody proposed to do this in userspace. This would be even not "inaccuracy",
the userspace time of read() is not correlated to real one at all
f.e. if userspace is going to do some dns, times will differ inpredictably.

Alexey
