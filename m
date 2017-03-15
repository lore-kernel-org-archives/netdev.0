From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] Add support for passing more information
 in mqprio offload
Date: Wed, 15 Mar 2017 15:20:44 -0700 (PDT)
Message-ID: <20170315.152044.339627206478364951.davem@davemloft.net>
References: <20170315172929.16349.95037.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.lendacky@amd.com,
        bkenward@solarflare.com, amritha.nambiar@intel.com,
        madalin.bucur@nxp.com, w-kwok2@ti.com, saeedm@mellanox.com,
        ariel.elior@cavium.com, m-karicheri2@ti.com,
        jeffrey.t.kirsher@intel.com, Yuval.Mintz@cavium.com,
        ecree@solarflare.com, michael.chan@broadcom.com,
        tariqt@mellanox.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdCOWWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:22:20 -0400
In-Reply-To: <20170315172929.16349.95037.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 15 Mar 2017 10:39:12 -0700

> This patch series lays the groundwork for future work to allow us to make
> full use of the mqprio options when offloading them to hardware.
> 
> Currently when we specify the hardware offload for mqprio the queue
> configuration is completely ignored and the hardware is only notified of
> the total number of traffic classes.  The problem is this leads to multiple
> issues, one specific issue being you can pass the queue configuration you
> want and it is totally ignored by the hardware.
> 
> What I am planning to do is add support for "hw" values in the
> configuration greater than 1.  So for example we might have one mode of
> mqprio offload that uses 1 and only offloads the TC counts like we
> currently do.  Then we might look at adding an option 2 which would factor
> in the TCs and the queue count information. This way we can select between
> the type of offload we actually want and existing drivers that don't
> support this can just fall back to their legacy configuration.

This looks fine, series applied, thanks Alex.
