From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw-phy-sel: Clear RGMII_IDMODE on
 "rgmii" links
Date: Tue, 06 Dec 2016 11:36:30 -0500 (EST)
Message-ID: <20161206.113630.1454582039498444818.davem@davemloft.net>
References: <1480988033-16535-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gokhan@adaptrum.com
To: alex.g@adaptrum.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbcLFQgc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:36:32 -0500
In-Reply-To: <1480988033-16535-1-git-send-email-alex.g@adaptrum.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandru Gagniuc <alex.g@adaptrum.com>
Date: Mon,  5 Dec 2016 17:33:53 -0800

> Support for setting the RGMII_IDMODE bit was added in commit:
> "drivers: net: cpsw-phy-sel: add support to configure rgmii internal delay"
> However, that commit did not add the symmetrical clearing of the bit
> by way of setting it in "mask". Add it here.
> 
> Note that the documentation marks clearing this bit as "reserved",
> however, according to TI, support for delaying the clock does exist in
> the MAC, although it is not officially supported.
> We tested this on a board with an RGMII to RGMII link that will not
> work unless this bit is cleared.
> 
> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>

Commits must be referenced by both short-form SHA1-ID as well as
the commit header text.

And since this change is fixing that commit, you should also provide
a proper "Fixes: " tag on the line right before your signoff.

Thanks.
