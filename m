From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid cache misses
Date: Fri, 8 Jun 2012 11:15:42 +0900
Message-ID: <20120608021542.GA10112@kroah.com>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
 <4FD11F49.5060805@gmail.com>
 <20120607.144358.1732928576389957779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, tarbal@gmail.com,
	rkagan@parallels.com, stable@vger.kernel.org,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	dnelson@redhat.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120607.144358.1732928576389957779.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07, 2012 at 02:43:58PM -0700, David Miller wrote:
> From: Jeff Kirsher <tarbal@gmail.com>
> Date: Thu, 07 Jun 2012 14:38:17 -0700
> 
> > Thanks! I have applied the patch to my queue
> 
> Why?
> 
> My impression is that this is a patch already in the tree, and it's
> being submitted for -stable but such minor performance hacks are
> absolutely not appropriate for -stable submission.

The patch description says it is fixing reported oopses, but the
Subject: isn't all that helpful there.

So which is this?  Should I accept it for a stable release or not?

thanks,

greg k-h
