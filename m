From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [UPDATED PATCH] ixgbe: fix vlan filtering
Date: Tue, 26 Aug 2008 19:12:01 -0700
Message-ID: <20080826191201.9689dd7d.akpm@linux-foundation.org>
References: <20080827013004.5497.48208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	stable@kernel.org, Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38746 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbYH0CMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 22:12:47 -0400
In-Reply-To: <20080827013004.5497.48208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Aug 2008 18:30:04 -0700 Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> VLAN filtering is broken, due to reading the incorrect register for the VLAN filtering settings.  Fixed by reading/writing the correct register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Please note that this patch does not successfully apply to 2.6.25 nor
to 2.6.26.  I didn't check why.

The -stable maintainers might appreciate separate checked-and-tested
backports for those kernels.

Thanks.
