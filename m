From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: uapi: MAX_ADDR_LEN vs. numeric 32
Date: Sat, 5 Aug 2017 01:34:49 +0300
Message-ID: <20170804223449.GD28459@lakka.kapsi.fi>
References: <20170804213325.GC28459@lakka.kapsi.fi>
 <20170804222519.GA11085@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@virtuozzo.com>
To: "Dmitry V. Levin" <ldv@altlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([91.232.154.25]:45006 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751342AbdHDWev (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 18:34:51 -0400
Content-Disposition: inline
In-Reply-To: <20170804222519.GA11085@altlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 05, 2017 at 01:25:19AM +0300, Dmitry V. Levin wrote:
>
> On Sat, Aug 05, 2017 at 12:33:25AM +0300, Mikko Rapeli wrote:
> > 
> > I find using MAX_ADDR_LEN better than numeric 32, though I doubt this will
> > change any time soon. Would you mind if I change packet_diag.h and
> > if_link.h to use that instead and fix the userspace compilation
> > problems by including netdevice.h?
> 
> The alternative fix, that is, to include <linux/netdevice.h>
> which pulls in other headers and a lot of definitions with them,
> has been mentioned in the discussion, too.
> We decided that the fix that was applied would be the least of all evils.

Ok, that's fine then. I'll drop my netdevice.h inclusion patch.

Thanks,

-Mikko
