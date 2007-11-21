From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v2] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Tue, 20 Nov 2007 17:38:04 -0800 (PST)
Message-ID: <20071120.173804.34897945.davem@davemloft.net>
References: <cac0ab7d0711200828n3548fadn48cce2837ed6a7c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: the.sator@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758622AbXKUBiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:38:05 -0500
In-Reply-To: <cac0ab7d0711200828n3548fadn48cce2837ed6a7c6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jonas Danielsson" <the.sator@gmail.com>
Date: Tue, 20 Nov 2007 17:28:22 +0100

> Fix arp reply when received arp probe with sender ip 0.
> 
> Send arp reply with target ip address 0.0.0.0 and target hardware address
> set to hardware address of requester. Previously sent reply with target
> ip address and target hardware address set to same as source fields.
> 
> 
> Signed-off-by: Jonas Danielsson <the.sator@gmail.com>
> Acked-by: Alexey Kuznetov <kuznet@ms2.inr.ac.ru>

I'm applying this but you gmail folks really have to get your
act together when submitting patches.  The patches from gmail
accounts come out corrupted 9 times out of 10.

This time line breaks were added and all tab characters were
turned into spaces.

Please correct this before any future patch submissions.
