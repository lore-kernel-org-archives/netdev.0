From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Wed, 10 Nov 2010 00:15:07 -0600
Message-ID: <20101110061507.GF4330@sgi.com>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
 <20101002112419.248437367@gulag1.americas.sgi.com>
 <1286025736.2582.1827.camel@edumazet-laptop>
 <20101005.145055.63017205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, holt@sgi.com,
	akpm@linux-foundation.org, w@1wt.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:48672 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997Ab0KJGQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 01:16:17 -0500
Content-Disposition: inline
In-Reply-To: <20101005.145055.63017205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 05, 2010 at 02:50:55PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 02 Oct 2010 15:22:16 +0200
> 
> > [PATCH] net: avoid limits overflow
> > 
> > Robin Holt tried to boot a 16TB machine and found some limits were
> > reached : sysctl_tcp_mem[2], sysctl_udp_mem[2]
> > 
> > We can switch infrastructure to use long "instead" of "int", now
> > atomic_long_t primitives are available for free.
> > 
> > Reported-by: Robin Holt <holt@sgi.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Eric please resubmit this when the sysctl fix is resolved.

It looks like the sysctl fix is upstream.  Has this been resubmitted
and I missed it?

Robin
