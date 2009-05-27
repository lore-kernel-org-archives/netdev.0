From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 3/4] ixgbe: remove rx_hdr_split debug
 counter for non-debug configurations
Date: Wed, 27 May 2009 12:16:57 +0100
Message-ID: <1243423017.16597.143.camel@deadeye>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
	 <20090527005445.28535.9069.stgit@localhost.localdomain>
	 <20090526.203810.50281143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35245 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763099AbZE0LRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 07:17:00 -0400
In-Reply-To: <20090526.203810.50281143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-05-26 at 20:38 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 26 May 2009 17:54:45 -0700
> 
> > The counter rx_hdr_split was meant to be a debug counter.  As such it
> > should only be enabled when debugging.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> I disagree with this change.
> 
> Any statistic is useful for diagnosing problems by users, and
> if you hide it behind DEBUG then users never see the facility.
> 
> Either it's unconditionally in the driver or it's unconditionally out.
> I say keep it in :-)

If rx_hdr_split means the same thing at Intel as it does here, it's a
hardware feature Microsoft wants for use in Hyper-V and it won't be
enabled under Linux.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
