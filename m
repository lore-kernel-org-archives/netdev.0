From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Thu, 17 Jul 2008 19:03:15 -0700 (PDT)
Message-ID: <20080717.190315.186892939.davem@davemloft.net>
References: <20080717214222.GA29449@elte.hu>
	<19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: vegard.nossum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751672AbYGRCDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 22:03:16 -0400
In-Reply-To: <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vegard Nossum" <vegard.nossum@gmail.com>
Date: Fri, 18 Jul 2008 01:15:47 +0200

> On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
> >
> > A regression to v2.6.26:
> >
> > I started getting this skb-head corruption message today, on a T60
> > laptop with e1000:
> >
> > PM: Removing info for No Bus:vcs11
> > device: 'vcs11': device_create_release
> > =============================================================================
> > BUG skbuff_head_cache: Poison overwritten
> > -----------------------------------------------------------------------------
> >
> > INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
> 
> 1. Notice the range. It's just a single byte.
> 2. Notice the value. It's just a ++.

It's supposed to be 0x6b, this would be a "--"

Also it (more likely IMHO) could be clearing a flag with the value 0x01.

