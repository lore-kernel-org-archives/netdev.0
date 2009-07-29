From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific members
Date: Wed, 29 Jul 2009 13:31:21 +0300
Message-ID: <200907291331.22265.opurdila@ixiacom.com>
References: <4A6DC314.2010303@ixiacom.com> <200907281743.27871.opurdila@ixiacom.com> <20090728.102808.228535949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lgrijincu@ixiacom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27055 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751123AbZG2Kd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 06:33:26 -0400
In-Reply-To: <20090728.102808.228535949.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 July 2009 20:28:08 David Miller wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Tue, 28 Jul 2009 17:43:27 +0300
>
> > On Monday 27 July 2009 18:26:44 David Miller wrote:
> >> This benefits, at best, %0.000000001 of users of the Linux kernel,
> >> because every distribution is going to turn on every single option.
> >
> > Not all Linux users are using regular (desktop/server) distributions.
>
> I didn't say all, I said "nearly all" which for many considerations
> is roughly equivalent.
>
> That %0.0000000001 was meant to represent non-distribution users.

There are many embedded / dedicated devices out there which use a customized 
Linux kernel (wireless routers and other network appliances, set-top boxes, 
TVs, etc.). 

I have no idea about what the actual percent of the Linux users these account 
for, but to dismiss it as  %0.0000000001 seems like a rush statement to me.

tavi

