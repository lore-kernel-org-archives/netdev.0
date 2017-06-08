From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] net: mvpp2: fixes and cleanups
Date: Thu, 08 Jun 2017 16:11:09 -0400 (EDT)
Message-ID: <20170608.161109.392184322028755789.davem@davemloft.net>
References: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        nadavh@marvell.com, hannah@marvell.com, yehuday@marvell.com,
        antoine.tenart@free-electrons.com,
        gregory.clement@free-electrons.com, elfring@users.sourceforge.net,
        marc.zyngier@arm.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751683AbdFHULM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:11:12 -0400
In-Reply-To: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Thu,  8 Jun 2017 17:27:22 +0200

> Here is a small set of fixes/improvements for the mvpp2 driver.
> 
> The first two patches are fixes: they fix bogus usage of
> smp_processor_id() in a migration-enabled context. Indeed currently
> the driver outputs some fat warnings in CONFIG_DEBUG_PREEMPT-enabled
> kernels. Therefore, some fixes should be pushed to stable.
> 
> The last three patches are cleanups and not needed for stable, but
> they stack on top of the fixes.

Please do not mix genuine bug fixes and cleanups.

You must submit them separately.

Send the fixes targetting 'net', and once those are accepted and
'net' is merged into 'net-next', you can submit the cleanups.

Thank you.
