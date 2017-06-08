From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/2][pull request] 1GbE Intel Wired LAN Driver
 Updates 2017-06-07
Date: Thu, 08 Jun 2017 14:41:38 -0400 (EDT)
Message-ID: <20170608.144138.1495526638857980394.davem@davemloft.net>
References: <20170608053237.73040-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHSll (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:41:41 -0400
In-Reply-To: <20170608053237.73040-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  7 Jun 2017 22:32:35 -0700

> This series contains a fix for e1000e and igb.
> 
> Colin Ian King fixes sparse warnings in igb by making functions static.
> 
> Chris Wilson provides a fix for a previous commit which is causing an
> issue during suspend "e1000e_pm_suspend()", where we need to run
> e1000e_pm_thaw() if __e1000_shutdown() is unsuccessful.

Series applied, thanks Jeff.
