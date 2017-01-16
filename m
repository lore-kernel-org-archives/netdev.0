From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] be2net: fix status check in be_cmd_pmac_add()
Date: Sun, 15 Jan 2017 23:49:58 -0500 (EST)
Message-ID: <20170115.234958.2283458238322647964.davem@davemloft.net>
References: <20170113213829.22722-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: cera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750845AbdAPEuA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 23:50:00 -0500
In-Reply-To: <20170113213829.22722-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <cera@cera.cz>
Date: Fri, 13 Jan 2017 22:38:27 +0100

> Return value from be_mcc_notify_wait() contains a base completion status
> together with an additional status. The base_status() macro need to be
> used to access base status.
> 
> Fixes: e3a7ae2 be2net: Changing MAC Address of a VF was broken
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Ivan Vecera <cera@cera.cz>

Applied.
