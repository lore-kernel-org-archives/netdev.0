From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Tue, 08 Jul 2008 15:02:57 -0700 (PDT)
Message-ID: <20080708.150257.41516850.davem@davemloft.net>
References: <4873B6E1.9010702@trash.net>
	<20080708193351.GE14330@xi.wantstofly.org>
	<4873CAFB.8040606@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, nico@cam.org, dale@farnsworth.org,
	akarkare@marvell.com, jdb@comx.dk, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbYGHWC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:02:57 -0400
In-Reply-To: <4873CAFB.8040606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Jul 2008 22:15:55 +0200

> Lennert Buytenhek wrote:
> > On Tue, Jul 08, 2008 at 08:50:09PM +0200, Patrick McHardy wrote:
> > 
> >> commit 9381fc4a49cb8b75d5ff38e4f5d14d7e135adc4c
> >> Author: Patrick McHardy <kaber@trash.net>
> >> Date:   Tue Jul 8 19:56:17 2008 +0200
> >>
> >>     vlan: avoid header copying and linearisation where possible
> > 
> > That gives me:
> > 
> > - 2.6.26-rc9 + [1] + [2] + this patch: ~75 sec, 13.6 MiB/s
> > 
> > So it's almost back to the non-VLAN case.
> 
> 
> Great, thanks. The patch applies cleanly with or without the VLAN
> packet socket patches I sent today, so Dave can either just apply
> it together with your mv643xx_eth patch or I'll include it when
> sending the next VLAN update.

Patrick, want me to stuff this one into net-2.6?

BTW, there is a typo in the commit message, you say
"skb_cow_header()" which doesn't exist, you mean "skb_cow_head()".
But you got it right in the code :)
