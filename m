From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Initialize on-stack cork more efficiently.
Date: Fri, 06 May 2011 15:59:01 -0700 (PDT)
Message-ID: <20110506.155901.35049431.davem@davemloft.net>
References: <20110506.152623.232747437.davem@davemloft.net>
	<1304721894.11874.28.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57364
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752361Ab1EFW7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 18:59:34 -0400
In-Reply-To: <1304721894.11874.28.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 06 May 2011 15:44:54 -0700

> Perhaps it'd be better to move the initialization
> of all cork fields to ip_setup_cork.

We can't, the flags and other fields can be setup way up high in the
call chain when the inet->cork instance is used.

I'll fix the NULL assignment, thanks.
