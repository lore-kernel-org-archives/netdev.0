From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] ixgbe: remove rx_hdr_split debug
 counter for non-debug configurations
Date: Tue, 26 May 2009 20:38:10 -0700 (PDT)
Message-ID: <20090526.203810.50281143.davem@davemloft.net>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
	<20090527005445.28535.9069.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48869
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756297AbZE0DiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:38:11 -0400
In-Reply-To: <20090527005445.28535.9069.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 May 2009 17:54:45 -0700

> The counter rx_hdr_split was meant to be a debug counter.  As such it
> should only be enabled when debugging.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I disagree with this change.

Any statistic is useful for diagnosing problems by users, and
if you hide it behind DEBUG then users never see the facility.

Either it's unconditionally in the driver or it's unconditionally out.
I say keep it in :-)

