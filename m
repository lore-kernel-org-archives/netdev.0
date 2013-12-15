From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] igb: Fix for issue where values could be too high
 for udelay function.
Date: Sat, 14 Dec 2013 23:00:20 -0500 (EST)
Message-ID: <20131214.230020.446173956038919190.davem@davemloft.net>
References: <1387020406-7964-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1387020406-7964-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	sunil.k.pandey@intel.com, kevin.b.smith@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab3LOEAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 23:00:22 -0500
In-Reply-To: <1387020406-7964-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 14 Dec 2013 03:26:46 -0800

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch changes the igb_phy_has_link function to check the value of the
> parameter before deciding to use udelay or mdelay in order to be sure that
> the value is not too high for udelay function.
> 
> CC: stable kernel <stable@vger.kernel.org> # 3.9+
> Signed-off-by: Sunil K Pandey <sunil.k.pandey@intel.com>
> Signed-off-by: Kevin B Smith <kevin.b.smith@intel.com>
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
