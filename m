From: David Miller <davem@davemloft.net>
Subject: Re: Overflow bug in Vegas
Date: Wed, 30 Apr 2008 01:06:27 -0700 (PDT)
Message-ID: <20080430.010627.236416568.davem@davemloft.net>
References: <aa7d2c6d0804091357i10aa16f8sf8d99dbaaa7f0542@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lachlan.andrew@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755261AbYD3IG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 04:06:29 -0400
In-Reply-To: <aa7d2c6d0804091357i10aa16f8sf8d99dbaaa7f0542@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Date: Wed, 9 Apr 2008 13:57:23 -0700

> Greetings all,
> 
> There is an overflow bug in  net/ipv4/tcp_vegas.c  for large BDPs
> (e.g. 400Mbit/s, 400ms).
> The multiplication  (old_wnd * vegas->baseRTT) << V_PARAM_SHIFT
> overflows a  u32.
> 
> The attached patch relative to 2.6.25-rc7 fixes that.
> 
> (No-one would ever use Vegas on a path like that, but it will affect
> algorithms derived from the Vegas code.  I found the bug while testing
> the Linux port of Microsoft's Compound TCP, from
> <http://netlab.caltech.edu/lachlan/ctcp/>.  That patch is derived from
> Angelo Castellani's which used the Vegas code.)

tcp_veno.c had similar calculations, so I fixed those up too when
I applied your patch.

Thanks.
