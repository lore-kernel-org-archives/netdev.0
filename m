From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
Date: Wed, 21 Jul 2010 09:50:55 -0700
Message-ID: <20100721165055.GE13188@sequoia.sous-sol.org>
References: <1279730431-17156-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, chrisw@sous-sol.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:59770 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750986Ab0GUQvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 12:51:00 -0400
Content-Disposition: inline
In-Reply-To: <1279730431-17156-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Andy Gospodarek (andy@greyhouse.net) wrote:
> Some ixgbe cards put an invalid VF device ID in the PCIe SR-IOV
> capability.  The ixgbe driver is only valid for PFs or non SR-IOV
> hardware.  It seems that the same problem could occur on igb hardware as
> well, so if we discover we are trying to initialize a VF in ixbge_probe
> or igb_probe, print an error and exit.
> 
> Based on a patch for ixgbe from Chris Wright <chrisw@sous-sol.org>.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Cc: Chris Wright <chrisw@sous-sol.org>

Acked-by: Chris Wright <chrisw@sous-sol.org>

Only seen this on ixgbe, but since the result there is a kernel panic
makes sense to be defensive.

thanks,
-chris
