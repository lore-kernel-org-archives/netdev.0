From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Prevent inner-reload while VFs exist
Date: Wed, 22 Apr 2015 14:23:58 -0400 (EDT)
Message-ID: <20150422.142358.1119355017978517408.davem@davemloft.net>
References: <1429696052-27666-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbbDVSYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 14:24:02 -0400
In-Reply-To: <1429696052-27666-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 22 Apr 2015 12:47:32 +0300

> On some feature changes, driver employes an inner-reload flow where it
> resets the function and re-configures it with the new required set of
> parameters.
> 
> Such a flow proves fatal to any VF since those were not intended to be used
> while HW is being reset underneath, causing them [at best] to lose all
> connectivity.
> 
> This changes driver behavior to fail all configuration changes [e.g., mtu
> change] requested of the driver in case VFs are active.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
