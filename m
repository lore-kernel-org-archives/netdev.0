From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Mon, 18 Oct 2010 12:43:39 -0500
Message-ID: <20101018174339.GC14068@sgi.com>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
 <20101002112419.248437367@gulag1.americas.sgi.com>
 <20101005.145032.25126909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: holt@sgi.com, w@1wt.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:53671 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757470Ab0JRRoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 13:44:18 -0400
Content-Disposition: inline
In-Reply-To: <20101005.145032.25126909.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 05, 2010 at 02:50:32PM -0700, David Miller wrote:
> From: Robin Holt <holt@sgi.com>
> Date: Sat, 02 Oct 2010 06:24:06 -0500
> 
> > Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers to prevent integer overflows.
> > 
> > On a 16TB x86_64 machine, sysctl_tcp_mem[2], sysctl_udp_mem[2], and
> > sysctl_sctp_mem[2] can integer overflow.  Set limit such that they are
> > maximized without overflowing.
> > 
> > Signed-off-by: Robin Holt <holt@sgi.com>
> 
> Robin please resubmit this with the SCTP bits included.

David,

I did not mean to blow you off.  I was not going to resubmit because
Eric's patch is the preferred direction.  I had been given an indication
that my patch was preferred, but that indicator changed.

Robin
