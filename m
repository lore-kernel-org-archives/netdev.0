From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: fix unicast list filling
Date: Sat, 07 Jan 2017 21:27:40 -0500 (EST)
Message-ID: <20170107.212740.1226435999696907045.davem@davemloft.net>
References: <20170106205930.3996-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: cera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933053AbdAHC1s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 21:27:48 -0500
In-Reply-To: <20170106205930.3996-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <cera@cera.cz>
Date: Fri,  6 Jan 2017 21:59:30 +0100

> The adapter->pmac_id[0] item is used for primary MAC address but
> this is not true for adapter->uc_list[0] as is assumed in
> be_set_uc_list(). There are N UC addresses copied first from net_device
> to adapter->uc_list[1..N] and then N UC addresses from
> adapter->uc_list[0..N-1] are sent to HW. So the last UC address is never
> stored into HW and address 00:00:00:00;00:00 (from uc_list[0]) is used
> instead.
> 
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Fixes: b717241 be2net: replace polling with sleeping in the FW completion path
> Signed-off-by: Ivan Vecera <cera@cera.cz>

Applied, thanks.
