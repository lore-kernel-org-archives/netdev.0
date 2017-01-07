From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: fix accesses to unicast list
Date: Fri, 06 Jan 2017 22:22:36 -0500 (EST)
Message-ID: <20170106.222236.506698272549757948.davem@davemloft.net>
References: <20170106193002.32727-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: cera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750887AbdAGDWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:22:38 -0500
In-Reply-To: <20170106193002.32727-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <cera@cera.cz>
Date: Fri,  6 Jan 2017 20:30:02 +0100

> Commit 988d44b "be2net: Avoid redundant addition of mac address in HW"
> introduced be_dev_mac_add & be_uc_mac_add helpers that incorrectly
> access adapter->uc_list as an array of bytes instead of an array of
> be_eth_addr. Consequently NIC is not filled with valid data so unicast
> filtering is broken.
> 
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Fixes: 988d44b be2net: Avoid redundant addition of mac address in HW
> Signed-off-by: Ivan Vecera <cera@cera.cz>

Applied.
