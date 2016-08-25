From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: systemport: Fix ordering in intrl2_*_mask_clear
 macro
Date: Thu, 25 Aug 2016 16:53:04 -0700 (PDT)
Message-ID: <20160825.165304.48121821754573992.davem@redhat.com>
References: <1472073701-24289-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39038 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752567AbcHYXxF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:53:05 -0400
In-Reply-To: <1472073701-24289-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 24 Aug 2016 14:21:41 -0700

> Since we keep shadow copies of which interrupt sources are enabled
> through the intrl2_*_mask_{set,clear} macros, make sure that the
> ordering in which we do these two operations: update the copy, then
> unmask the register is correct.
> 
> This is not currently a problem because we actually do not use them, but
> we will in a subsequent patch optimizing register accesses, so better be
> safe here.
> 
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David,
> 
> This is intentionally targetting the "net-next" tree since it is
> not yet a problem, yet this is still technically a bugfix. No need
> to backport this to -stable or anything.

Fair enough, applied to net-next.

Thanks!
