From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: require speed/duplex only for 802.3ad, alb
 and tlb
Date: Fri, 11 Aug 2017 14:22:25 -0700 (PDT)
Message-ID: <20170811.142225.600534251833546349.davem@davemloft.net>
References: <20170810044144.17398-1-futur.andy@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: futur.andy@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbdHKVW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:22:26 -0400
In-Reply-To: <20170810044144.17398-1-futur.andy@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Born <futur.andy@googlemail.com>
Date: Thu, 10 Aug 2017 06:41:44 +0200

> The patch c4adfc822bf5 ("bonding: make speed, duplex setting consistent
> with link state") puts the link state to down if
> bond_update_speed_duplex() cannot retrieve speed and duplex settings.
> Assumably the patch was written with 802.3ad mode in mind which relies
> on link speed/duplex settings. For other modes like active-backup these
> settings are not required. Thus, only for these other modes, this patch
> reintroduces support for slaves that do not support reporting speed or
> duplex such as wireless devices. This fixes the regression reported in
> bug 196547 (https://bugzilla.kernel.org/show_bug.cgi?id=196547).
> 
> Fixes: c4adfc822bf5 ("bonding: make speed, duplex setting consistent
> with link state")
> Signed-off-by: Andreas Born <futur.andy@googlemail.com>

Applied and queued up for -stable, thanks.
