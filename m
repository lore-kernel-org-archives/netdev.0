From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 19:53:28 +0100
Message-ID: <20080131185328.GD4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49695 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934251AbYAaSTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:19:02 -0500
Content-Disposition: inline
In-Reply-To: <20080131100846.00934e25@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Then change TBF to use skb_gso_segment?  Be careful, the fact that

That doesn't help because it wants to interleave packets
from different streams to get everything fair and smooth. The only 
good way to handle that is to split it up and the simplest way to do 
this is to just tell TCP to not do GSO in the first place.

-Andi

