From: David Miller <davem@davemloft.net>
Subject: Re: [net 3/8] ixgbe: fix vf lookup
Date: Wed, 08 Feb 2012 18:33:14 -0500 (EST)
Message-ID: <20120208.183314.265645315647132912.davem@davemloft.net>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1328693798-27323-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757587Ab2BHXdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 18:33:18 -0500
In-Reply-To: <1328693798-27323-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  8 Feb 2012 01:36:33 -0800

> -		if (pvfdev->devfn == vf_devfn)
> +		if (pvfdev->devfn == vf_devfn &&
> +				(pvfdev->bus->number >= pdev->bus->number))

Come on.... do you look at these patches at all?

I don't think you did, because this kind of code formatting stuff
sticks out like a sore thumb.
