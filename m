From: David Miller <davem@davemloft.net>
Subject: Re: can-bcm: fix minor heap overflow
Date: Fri, 12 Nov 2010 14:07:34 -0800 (PST)
Message-ID: <20101112.140734.57456267.davem@davemloft.net>
References: <4CDB1856.4040001@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com,
	torvalds@linux-foundation.org, urs@isnogud.escape.de,
	security@kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757467Ab0KLWHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 17:07:10 -0500
In-Reply-To: <4CDB1856.4040001@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 10 Nov 2010 23:10:30 +0100

> On 64-bit platforms the ASCII representation of a pointer may be up to 17
> bytes long. This patch increases the length of the buffer accordingly.
> 
> http://marc.info/?l=linux-netdev&m=128872251418192&w=2
> 
> Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> CC: Linus Torvalds <torvalds@linux-foundation.org>

Patch applied, thanks.
