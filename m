From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft
 RFC 2988bis-02.
Date: Thu, 19 May 2011 15:27:03 -0400 (EDT)
Message-ID: <20110519.152703.1327182804872376183.davem@davemloft.net>
References: <BANLkTimSZEbnNVzi3UvBFndHp25S0ow7YQ@mail.gmail.com>
	<1456193D-84D1-46E2-B930-8FD0A5B8C409@comsys.rwth-aachen.de>
	<BANLkTikZasOVfr2zTfXVjPqQsnzy9Hk5uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.zimmermann@comsys.rwth-aachen.de, hagen@jauu.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsunanet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikZasOVfr2zTfXVjPqQsnzy9Hk5uA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: tsuna <tsunanet@gmail.com>
Date: Thu, 19 May 2011 10:11:50 -0700

> Looking through the kernel, I see that SCTP already has knobs for
> this: sctp_rto_initial, sctp_rto_min, sctp_rto_max.  You can even
> control the constants used to update rttvar and srtt: sctp_rto_alpha,
> sctp_rto_beta

SCTP is 1) not even a sliver of deployment compared to TCP and 2)
doesn't get nearly the same scrutiny on patch review that TCP
changes do.

I basically let the SCTP folks play in their own sandbox, because
frankly SCTP doesn't matter.

The only time I care about an SCTP change is when it has an impact on
the rest of the networking code.

So using SCTP as an example of "see we do this already over here" is a
non-starter.  Don't do it.
