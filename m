From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] qed: load/unload mfw series
Date: Tue, 28 Mar 2017 18:06:30 -0700 (PDT)
Message-ID: <20170328.180630.1922828951739768604.davem@davemloft.net>
References: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39998 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932571AbdC2BGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 21:06:32 -0400
In-Reply-To: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Tue, 28 Mar 2017 15:12:49 +0300

> This series correct the unload flow and greatly enhances its
> initialization flow in regard to interactions between driver
> and management firmware.
> 
> Patch #1 makes sure unloading is done under management-firmware's
> 'criticial section' protection.
> 
> Patches #2 - #4 move driver into using a newer scheme for loading
> in regard to the MFW; This newer scheme would help cleaning the device
> in case a previous instance has dirtied it [preboot, PDA, etc.].
> 
> Patches #5 - #6 let driver inform management-firmware on number of
> resources which are dependent on the non-management firmware used.
> Patch #7 then uses a new resource [BDQ] instead of some set value.

Series applied, thank you.
