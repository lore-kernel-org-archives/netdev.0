From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv4] Add strict check for replying net unreachable
 message
Date: Thu, 06 Dec 2007 22:41:24 -0800 (PST)
Message-ID: <20071206.224124.215803565.davem@davemloft.net>
References: <20071207132418.d19d2f0e.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roszenrami@gmail.com, jarkao2@gmail.com
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbXLGGlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 01:41:24 -0500
In-Reply-To: <20071207132418.d19d2f0e.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Fri, 7 Dec 2007 13:24:18 +0900

> The patch `Reply net unreachable ICMP message' had a bug.
> A route whose type is blockhole or prohibit type is treated as
> unreachable type. The case where err is set to ENETUNREACH should
> be that no route is found in the routing table only.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Applied, thanks.

I'll probably combine this with your original change before I
push these changes upstream.
