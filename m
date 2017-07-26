From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 0/5][pull request] 10GbE Intel Wired LAN Driver
 Updates 2017-07-25
Date: Wed, 26 Jul 2017 16:36:45 -0700 (PDT)
Message-ID: <20170726.163645.949463595632932191.davem@davemloft.net>
References: <20170725234138.42283-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdGZXgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 19:36:46 -0400
In-Reply-To: <20170725234138.42283-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 25 Jul 2017 16:41:33 -0700

> This series contains updates to ixgbe only.
> 
> Tony provides all of the changes in the series, starting with adding a
> check to ensure that adding a MAC filter was successful, before setting the
> MACVLAN.  In order to receive notifications of link configurations of the
> external PHY and support the configuration of the internal iXFI link on
> X552 devices, Tony enables LASI interrupts.  Update the iXFI driver code
> flow, since the MAC register NW_MNG_IF_SEL fields have been redefined for
> X553 devices, so add MAC checks for iXFI flows.  Added additional checks
> for flow control autonegotiation, since it is not support for X553 fiber
>  and XFI devices.
> 
> v2: removed unnecessary parens noticed by David Miller in patch 6 of the
>     series.
> v3: dropped patch 6 of the original series, while we work out a more
>     generic solution for malicious driver detection (MDD) support.
> v4: updated patch 1 of the series with the comments from Joe Perches which
>     were:
>       - switched logic to return on error
>       - return 0 on success
>       - declare retval as an integer
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Pulled, thanks Jeff!
