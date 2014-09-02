From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/3] amd-xgbe: AMD XGBE driver updates
 2014-08-29
Date: Mon, 01 Sep 2014 20:31:52 -0700 (PDT)
Message-ID: <20140901.203152.216310411574954349.davem@davemloft.net>
References: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbaIBDbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 23:31:53 -0400
In-Reply-To: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 29 Aug 2014 10:21:48 -0500

> The amd-xgbe-phy phylib driver support is integral to the amd-xgbe
> driver and isn't meant to be used by other devices.  For this reason
> it is being removed from the driver/net/phy directory and integrated
> into the amd-xgbe driver.

I see no real reason to do this.

Keeping it in the phylib layer forces you to deal with the abstractions
and therefore keeps you from bypassing the phylib API and performing
layer violations.

Please just keep the PHY driver where it is and add your new features
there.

Thanks.
