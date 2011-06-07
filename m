From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6] igb: fix i350 SR-IOV failture
Date: Tue, 07 Jun 2011 14:23:05 -0700 (PDT)
Message-ID: <20110607.142305.1023199011249895200.davem@davemloft.net>
References: <1307450339-9889-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757467Ab1FGVXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 17:23:11 -0400
In-Reply-To: <1307450339-9889-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  7 Jun 2011 05:38:59 -0700

> From: "Williams, Mitch A" <mitch.a.williams@intel.com>
> 
> When SR-IOV is enabled, i350 devices fail to pass traffic. This is due to
> the driver attempting to enable RSS on the PF device, which is not
> supported by the i350.
> 
> When max_vfs is specified on an i350 adapter, set the number of RSS queues
> to 1.
> 
> This issue affects 2.6.39 as well.
> 
> CC: stable@kernel.org
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
