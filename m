From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/13] nfp: pci core, hwmon, live mac addr
 change
Date: Tue, 30 May 2017 11:53:42 -0400 (EDT)
Message-ID: <20170530.115342.1097144834047262548.davem@davemloft.net>
References: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdE3Pxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:53:51 -0400
In-Reply-To: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sun, 28 May 2017 17:52:51 -0700

> This series brings updates to core PCI code, SR-IOV, exposes 
> firmware's capability to change MAC address at runtime and HWMON
> interfaces.  
> 
> The PCI code updates include resiliency improvement in conditions 
> which are quite unusual, but still shouldn't make the driver oops.
> We also handle very large device memory operation more gracefully.
> A timeout is added to acquiring mutexes in device memory.
> 
> Pablo provides a patch to expose to the stack the ability to change
> MAC addresses under traffic while David adds HWMON interface for
> reading device temperature and power consumption.
> 
> Last three patches are minor improvements to the netdev code.
> 
> v2:
>  - add patch 1 - fix for devlink build;
>  - fix build issue with the hwmon patch.

Sereis applied, thanks.
