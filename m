From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Fix link problem on Dell's onboard 5906.
Date: Thu, 31 May 2007 14:50:24 -0700 (PDT)
Message-ID: <20070531.145024.52169518.davem@davemloft.net>
References: <1180649019.20882.3.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751970AbXEaVuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 17:50:11 -0400
In-Reply-To: <1180649019.20882.3.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 31 May 2007 15:03:39 -0700

> [TG3]: Fix link problem on Dell's onboard 5906.
> 
> The bug is caused by code that always set
> (TG3_FLAG_USE_MI_INTERRUPT | TG3_FLAG_USE_LINKCHG_REG) on all Dell's
> onboard devices.  With these 2 flags set, the link status is polled
> by tg3_timer() and will only work when the PHY is set up to interrupt
> the MAC on link changes.  This breaks 5906 because the 5906 PHY does
> not support TG3_FLAG_USE_MI_INTERRUPT the same as other PHYs.
> 
> For correctness, only Dell's onboard 5701 needs these 2 flags to be
> set.  This change will fix the 5906 problem and will change other
> Dell devices except 5700 and 5701 to use the more efficient
> interrupt-driven link changes.
> 
> Update version to 3.77.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied, thanks for fixing this bug Michael.

That Dell onboard chip logic is definitely my fault :)
