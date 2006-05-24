From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Thu, 25 May 2006 07:21:17 +1000
Message-ID: <20060524212117.GD5938@krispykreme>
References: <20060517220218.GA13411@myri.com> <20060517220608.GD13411@myri.com> <20060523153928.GB5938@krispykreme> <4474138C.2050705@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:16619 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932471AbWEXVYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 17:24:21 -0400
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <4474138C.2050705@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
Hi,

> We didn't get any ppc64 with PCI-E to run Linux so far. What performance
> drop should we expect with our current code ?

We have seen > 20% improvement on ppc64 running some networking
workloads when forcing 128 byte alignment (instead of 16 byte
alignment). DMA writes have to get cacheline aligned (in power of 2
steps) on some IO chips.

> I am not sure what you mean.
> The only ppc64 with PCI-E that we have seen so far (a G5) couldn't do
> write combining according to Apple.

Im thinking more generally, MTRRs are x86 specific and it would be good
to have a more generic way to enable write combining.

Anton
