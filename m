From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sfc: Firmware-Assisted TSO version 2
Date: Fri, 18 Nov 2016 12:03:09 -0500 (EST)
Message-ID: <20161118.120309.949387214421176408.davem@davemloft.net>
References: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bkenward@solarflare.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754360AbcKRRDO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 12:03:14 -0500
In-Reply-To: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 17 Nov 2016 10:49:42 +0000

> The firmware on 8000 series SFC NICs supports a new TSO API ("FATSOv2"), and
>  7000 series NICs will also support this in an imminent release.  This series
>  adds driver support for this TSO implementation.
> The series also removes SWTSO, as it's now equivalent to GSO.  This does not
>  actually remove very much code, because SWTSO was grotesquely intertwingled
>  with FATSOv1, which will also be removed once 7000 series supports FATSOv2.

Series applied, thanks.
