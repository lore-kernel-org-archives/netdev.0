From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Sat, 28 Feb 2009 23:36:53 +0100
Message-ID: <20090228223653.GD26292@one.firstfloor.org>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com> <87myc73izx.fsf@basil.nowhere.org> <c0a09e5c0902271753n1a522647g6e7ac5465149c5a4@mail.gmail.com> <20090228055608.GB26292@one.firstfloor.org> <c0a09e5c0902281244u356acbecn98f37ac3abd5ebc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Andy Grover <andy.grover@oracle.com>, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56618 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526AbZB1WSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 17:18:24 -0500
Content-Disposition: inline
In-Reply-To: <c0a09e5c0902281244u356acbecn98f37ac3abd5ebc0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The previous solution for IPC that Oracle was using was based on UDP,
> which I think could be considered very close to using raw sockets --
> each process is responsible for its own acks, retransmits, everything.
> Doing this on a highly loaded machine resulted in a cascade where
> performance got worse and worse.

Could you describe that cascade in more detail? 

The problem was that the retransmits didn't have high enough priority? 

> Additionally, our interconnect is primarily Infiniband. It natively
> implements a reliable datagram connection type so RDS leverages that.

So perhaps it would make more sense to have a thin direct interface
to that IB service? Or perhaps it already exists? (I admit I don't know
the IB interfaces very well) 

-andi

-- 
ak@linux.intel.com -- Speaking for myself only.
