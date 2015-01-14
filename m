From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net 0/3]tg3: synchronize_irq() should be called without
 taking locks
Date: Wed, 14 Jan 2015 11:04:22 -0800
Message-ID: <1421262262.16485.17.camel@prashant>
References: <1421217039-11689-1-git-send-email-prashant@broadcom.com>
	 <54B691FE.50903@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<mchan@broadcom.com>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:35236 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbANTWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:22:14 -0500
In-Reply-To: <54B691FE.50903@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 10:57 -0500, Peter Hurley wrote:
> On 01/14/2015 01:30 AM, Prashant Sreedharan wrote:
> > Prashant Sreedharan (3):
> >   tg3_timer() should grab tp->lock before checking for tp->irq_sync
> >   tg3_reset_task() needs to use rtnl_lock to synchronize
> >   Release tp->lock before invoking synchronize_irq()
> 
> Thanks!
> 
> For series:
> 
> Reported-by: Peter Hurley <peter@hurleysoftware.com>
> Tested-by: Peter Hurley <peter@hurleysoftware.com>
> 
> But maybe one of these patches should reference that this fixes
> BUG: sleeping function... so that others can quickly find this
> fix (if they're bisecting or whatever). 

Sure will add

> For the same reason, it
> might be useful for this series to be just one patch.

These are logical different sections of code, I prefer them to be small
patches.

> 
> Regards,
> Peter Hurley
> 
