From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ieee802154: fix faulty check in
 set_phy_params api
Date: Tue, 18 Feb 2014 18:11:34 -0500 (EST)
Message-ID: <20140218.181134.1567312251794761780.davem@davemloft.net>
References: <1392730767-24858-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbaBRXLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:11:36 -0500
In-Reply-To: <1392730767-24858-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Tue, 18 Feb 2014 14:39:27 +0100

> phy_set_csma_params has a redundant (and impossible) check for
> "retries", found by smatch. The check was supposed to be for
> frame_retries, but wasn't moved during development when
> phy_set_frame_retries was introduced. Also, maxBE >= 3 as required by
> the standard is not enforced.
> 
> Remove the redundant check, assure max_be >= 3 and check -1 <=
> frame_retries <= 7 in the correct function.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>

Applied.
