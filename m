From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: Do not clear RAR entry when clearing VMDq for SAN
 MAC
Date: Fri, 19 Aug 2016 22:39:58 -0700 (PDT)
Message-ID: <20160819.223958.1807954563469483233.davem@davemloft.net>
References: <1471665506-75138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbcHTFj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 01:39:59 -0400
In-Reply-To: <1471665506-75138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Aug 2016 20:58:26 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The RAR entry for the SAN MAC address was being cleared when we were
> clearing the VMDq pool bits.  In order to prevent this we need to add
> an extra check to protect the SAN MAC from being cleared.
> 
> Fixes: 6e982aeae ("ixgbe: Clear stale pool mappings")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
