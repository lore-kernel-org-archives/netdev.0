From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] bnxt_en: Misc. updates for net-next.
Date: Mon, 29 May 2017 23:24:42 -0400 (EDT)
Message-ID: <20170529.232442.2063879282909901778.davem@davemloft.net>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdE3DYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:24:44 -0400
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 29 May 2017 19:06:03 -0400

> The 1st 2 patches add short firmware message support for new VF devices.
> The 3rd patch adds a pci shutdown callback for the RDMA driver for proper
> shutdown.  The next 3 patches improve the doorbell operations by
> elimiating the double doorbell workaround on newer chips, and by adding
> xmit_more support.  The last patch adds a parameter to bnxt_set_dflt_rings().

Series applied, but where is the change that sets the new ulp_shutdown
method pointer to something?

Thanks.
