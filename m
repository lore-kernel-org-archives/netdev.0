From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] xen-netback: fix race condition on XenBus
 disconnect
Date: Sun, 12 Mar 2017 23:45:12 -0700 (PDT)
Message-ID: <20170312.234512.1149941089812979377.davem@davemloft.net>
References: <1489181782-120847-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        paul.durrant@citrix.com, jgross@suse.com, wei.liu2@citrix.com
To: igor.druzhinin@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdCMGpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:45:14 -0400
In-Reply-To: <1489181782-120847-1-git-send-email-igor.druzhinin@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Druzhinin <igor.druzhinin@citrix.com>
Date: Fri, 10 Mar 2017 21:36:22 +0000

> In some cases during XenBus disconnect event handling and subsequent
> queue resource release there may be some TX handlers active on
> other processors. Use RCU in order to synchronize with them.
> 
> Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>

Applied, thanks.
