From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] ixgbe: fix for 82599 erratum on Header Splitting
Date: Fri, 4 Mar 2011 23:44:19 -0800
Message-ID: <20110305074419.GA19596@suse.de>
References: <1299308767-28735-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Skidmore <donald.c.skidmore@intel.com>, stable@kernel.org,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39384 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab1CEHnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 02:43:42 -0500
Content-Disposition: inline
In-Reply-To: <1299308767-28735-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2011 at 11:06:07PM -0800, Jeff Kirsher wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> We have found a hardware erratum on 82599 hardware that can lead to
> unpredictable behavior when Header Splitting mode is enabled.  So
> we are no longer enabling this feature on affected hardware.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ixgbe/ixgbe_main.c |    4 ++++

I'm confused, why did you just send this patch to me?

What am I supposed to do with it?

greg k-h
