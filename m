From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: Fix kernel panic on enable/disable LLDP
Date: Thu, 01 Sep 2016 14:20:45 -0700 (PDT)
Message-ID: <20160901.142045.1724169627272941166.davem@davemloft.net>
References: <1472517506-74650-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.m.ertman@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753199AbcIAVUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:20:55 -0400
In-Reply-To: <1472517506-74650-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 29 Aug 2016 17:38:26 -0700

> From: Dave Ertman <david.m.ertman@intel.com>
> 
> If DCB is configured on the link partner switch with an
> unsupported traffic class configuration (e.g. non-contiguous TCs),
> the driver is flagging DCB as disabled.  But, for future DCB
> LLDPDUs, the driver was checking if the interface was DCB capable
> instead of enabled.  This was causing a kernel panic when LLDP
> was enabled/disabled on the link partner switch.
> 
> This patch corrects the situation by having the LLDP event handler
> check the correct flag in the pf structure.  It also cleans up the
> setting and clearing of the enabled flag for other checks.
> 
> Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
