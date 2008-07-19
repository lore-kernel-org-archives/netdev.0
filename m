From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: resolve tx multiqueue bug
Date: Fri, 18 Jul 2008 17:51:32 -0700 (PDT)
Message-ID: <20080718.175132.57732510.davem@davemloft.net>
References: <20080718165128.GC10471@solarflare.com>
	<20080718170529.GD10471@solarflare.com>
	<9929d2390807181704u4e969d2bpb39683b7160b4939@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbYGSAvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:51:33 -0400
In-Reply-To: <9929d2390807181704u4e969d2bpb39683b7160b4939@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Jul 2008 17:04:42 -0700

> On Fri, Jul 18, 2008 at 10:05 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > With the recent changes to tx mutiqueue, e1000 was not calling
> > netif_start_queue() before calling netif_wake_queue().
> > This causes an oops during loading of the driver.
> >
> > (Based on commit d55b53fff0c2ddb639dca04c3f5a0854f292d982.)
...
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks everyone.

Jeff, really, I think those wake/stop queue calls in the PHY link
state watching code of all of these drivers should just flat out
be removed.
