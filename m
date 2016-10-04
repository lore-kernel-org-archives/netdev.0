From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/3][pull request] 40GbE Intel Wired LAN Driver
 Updates 2016-10-03
Date: Mon, 03 Oct 2016 23:29:19 -0400 (EDT)
Message-ID: <20161003.232919.2196032099553351277.davem@davemloft.net>
References: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754059AbcJDD3Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 23:29:25 -0400
In-Reply-To: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  3 Oct 2016 19:25:00 -0700

> This series contains fixes to i40e only.
> 
> Stefan Assmann provides the changes in this series to resolve an issue
> where when we run out of MSIx vectors, iWARP gets disabled automatically.
> First adds a check for "no vectors left" during MSIx vector allocation
> for VMDq, which will prevent more vectors being allocated than available.
> Then fixed the MSIx vector redistribution when we reach the hardware limit
> for vectors so that additional features like VMDq, iWARP, etc do not get
> starved for vectors because the PF is hogging all the resources.  Lastly,
> fix the issue for flow director by moving the check for the reaching the
> vector limit earlier in the code so that a decision can be made on
> disabling flow director.
> 
> The following are changes since commit b9118b7221ebb12156d2b08d4d5647bc6076d6bb:
>   ptp: Fix resource leak in case of error
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Pulled, thanks Jeff.
