From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] be2net: don't delete MAC on close on
 unprivileged BE3 VFs
Date: Sun, 15 Jan 2017 23:50:03 -0500 (EST)
Message-ID: <20170115.235003.1665157078566148793.davem@davemloft.net>
References: <20170113213829.22722-1-cera@cera.cz>
        <20170113213829.22722-2-cera@cera.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: cera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58818 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdAPEuF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 23:50:05 -0500
In-Reply-To: <20170113213829.22722-2-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <cera@cera.cz>
Date: Fri, 13 Jan 2017 22:38:28 +0100

> BE3 VFs without FILTMGMT privilege are not allowed to modify its MAC,
> VLAN table and UC/MC lists. So don't try to delete MAC on such VFs.
> 
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Ivan Vecera <cera@cera.cz>

Applied.
