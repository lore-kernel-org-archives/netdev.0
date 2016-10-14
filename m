From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net 0/3] qed: Fix dependencies and warnings series
Date: Fri, 14 Oct 2016 08:51:09 +0200
Message-ID: <8307648.oIx4xWhFox@wuerfel>
References: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        dan.carpenter@oracle.com
To: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:62103 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752877AbcJNGv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 02:51:27 -0400
In-Reply-To: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, October 13, 2016 10:57:00 PM CEST Yuval Mintz wrote:
> Hi Dave,
> 
> The first patch in this series follows Dan Carpenter's reports about
> Smatch warnings for recent qed additions and fixes those.
> 
> The second patch is the most significant one [and the reason this is
> ntended for 'net'] - it's based on Arnd Bermann's suggestion for fixing
> compilation issues that were introduced with the roce addition as a result
> of certain combinations of qed, qede and qedr Kconfig options.
> 
> The third follows the discussion with Arnd and clears a lot of the warnings
> that arise when compiling the drivers with "C=1".
> 
> Please consider applying this series to 'net'.
> 

I've put all three patches into my randconfig test tree for double-checking,
but looking at the patches I'm fairly sure they are good.

I'll let you know within a few hours if something breaks unexpectedly.

Thanks for picking up my suggestions!

Acked-by: Arnd Bergmann <arnd@arndb.de>
