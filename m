From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 12:53:54 -0800 (PST)
Message-ID: <20091120.125354.222885799.davem@davemloft.net>
References: <4B05D8DC.7020907@gmail.com>
	<87aayg539l.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52810
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754452AbZKTUxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:53:37 -0500
In-Reply-To: <87aayg539l.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 20 Nov 2009 21:51:02 +0100

> -Andi (who is a bit sceptical and would rather see generic work for
> -this in slab)

SLAB does this to an extent, but it's the other things about
SKB freeing that are expensive and hits lots of cache misses
in these cases.
