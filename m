From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rfs: Don't reset RFS entries when
 nothing changed
Date: Mon, 22 May 2017 23:02:20 -0400 (EDT)
Message-ID: <20170522.230220.402998640470537222.davem@davemloft.net>
References: <1495500311-81095-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933122AbdEWDC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 23:02:28 -0400
In-Reply-To: <1495500311-81095-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Tue, 23 May 2017 08:45:11 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> When the new RFS table size specified by sysctl equals the old one,
> there is nothing changed actually. So it is unnecessary to reset the
> RFS table entris.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

It seems like an intentional feature to be able to reset the
table by simply writing the same value to the sysfs knob.

I'm not applying this, sorry.
