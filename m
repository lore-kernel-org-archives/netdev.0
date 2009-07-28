From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific members
Date: Tue, 28 Jul 2009 17:43:27 +0300
Message-ID: <200907281743.27871.opurdila@ixiacom.com>
References: <4A6DC314.2010303@ixiacom.com> <20090727.082644.265102452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lgrijincu@ixiacom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27025 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753141AbZG1Opd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 10:45:33 -0400
In-Reply-To: <20090727.082644.265102452.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 27 July 2009 18:26:44 David Miller wrote:

> From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
> Date: Mon, 27 Jul 2009 18:09:08 +0300
>
> > Some members of net_device are used only by some protocols.
> >
> > If those protocols are not compiled (as modules or linked in) they
> > should not take up space in the structure.
>
> This benefits, at best, %0.000000001 of users of the Linux kernel,
> because every distribution is going to turn on every single option.
>

Not all Linux users are using regular (desktop/server) distributions. Linux is 
used in embedded systems as well and in these case it makes sense to turn off 
ax25/econet/decnet and in some cases even wireless/ipv6.

> If you want to shrink structures, find ways to eliminate or
> shrink structure members in all cases.

We are looking into that as well since we have a pretty aggressive goal (get 
net_device to 450 bytes or so), but we thought of starting with the low 
hanging fruits. 

Any suggestions in this area?

tavi

