From: David Miller <davem@davemloft.net>
Subject: Re: [2/5][TG3]: Fix the polarity bit.
Date: Wed, 11 Jul 2007 19:48:03 -0700 (PDT)
Message-ID: <20070711.194803.00928690.davem@davemloft.net>
References: <1184196727.5211.9.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46240
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764979AbXGLCrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:47:40 -0400
In-Reply-To: <1184196727.5211.9.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 11 Jul 2007 16:32:07 -0700

> [TG3]: Fix the polarity bit.
> 
> For most pre-5705 devices, multiple link interrupts were being generated
> for a single physical link change.  The source of the interrupts was
> determined to be unnecessary toggling of the MAC link polarity bit.
> 
> This patch changes the way the link polarity bit gets configured.  Where
> possible, code that dynamically configures the bit in response to link
> changes has been replaced by code that configures the bit once during
> initialization time and then leaves the bit alone.
> 
> For correctness, this patch also limits the use of the bit to those
> devices where it is defined, namely devices before the 5705.  This patch
> also corrects the link polarity configurations for 5700 devices when
> paired against a bcm5411 phy.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
