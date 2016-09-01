From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tg3: Fix for disallow tx coalescing time to be 0
Date: Thu, 01 Sep 2016 09:58:09 -0700 (PDT)
Message-ID: <20160901.095809.1791445078754790512.davem@davemloft.net>
References: <1472722139-22806-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satish.baddipadige@broadcom.com,
        siva.kallam@broadcom.com, michael.chan@broadcom.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754008AbcIAU5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 16:57:21 -0400
In-Reply-To: <1472722139-22806-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu,  1 Sep 2016 11:28:59 +0200

> The recent commit 087d7a8c9174 "tg3: Fix for diasllow rx coalescing
> time to be 0" disallow to set Rx coalescing time to be 0 as this stops
> generating interrupts for the incoming packets. I found the zero
> Tx coalescing time stops generating interrupts for outgoing packets
> as well and fires Tx watchdog later. To avoid this, don't allow to set
> Tx coalescing time to 0 and also remove subsequent checks that become
> senseless.
> 
> Cc: satish.baddipadige@broadcom.com
> Cc: siva.kallam@broadcom.com
> Cc: michael.chan@broadcom.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.
