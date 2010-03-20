From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbevf: Fix VF Stats accounting after
 reset
Date: Fri, 19 Mar 2010 21:06:11 -0700 (PDT)
Message-ID: <20100319.210611.71090762.davem@davemloft.net>
References: <20100319125950.9799.70157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44603
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750772Ab0CTEFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:05:49 -0400
In-Reply-To: <20100319125950.9799.70157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Mar 2010 05:59:52 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The counters in the 82599 Virtual Function are not clear on read.  They
> accumulate to the maximum value and then roll over.  They are also not
> cleared when the VF executes a soft reset, so it is possible they are
> non-zero when the driver loads and starts.  This has all been accounted
> for in the code that keeps the stats up to date but there is one case
> that is not.  When the PF driver is reset the counters in the VF are
> all reset to zero.  This adds an additional accounting overhead into
> the VF driver when the PF is reset under its feet.  This patch adds
> additional counters that are used by the VF driver to accumulate and
> save stats after a PF reset has been detected.  Prior to this patch
> displaying the stats in the VF after the PF has reset would show
> bogus data.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
