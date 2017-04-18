From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: VxLAN offload should be re-enabled when
 only 1 UDP port is left
Date: Tue, 18 Apr 2017 15:56:36 -0400 (EDT)
Message-ID: <20170418.155636.2052322177519045840.davem@davemloft.net>
References: <20170417160313.1548-1-sriharsha.basavapatna@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44078 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755272AbdDRT4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:56:38 -0400
In-Reply-To: <20170417160313.1548-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Date: Mon, 17 Apr 2017 21:33:13 +0530

> We disable VxLAN offload when more than 1 UDP port is added to the driver,
> since Skyhawk doesn't support offload with multiple ports. The existing
> driver design expects the user to delete all port configurations and create
> a configuration with a single UDP port for VxLAN offload to be re-enabled.
> Remove this restriction by tracking the ports added and re-enabling offload
> when ports get deleted and only 1 port is left.
> 
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Reviewed-by: Sathya Perla <sathya.perla@broadcom.com>

Applied to net-next, thanks.
