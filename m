From: David Miller <davem@davemloft.net>
Subject: Re: Vague maybe ppp-related panic report for 2.6.23-rc9
Date: Thu, 04 Oct 2007 13:51:13 -0700 (PDT)
Message-ID: <20071004.135113.48807663.davem@davemloft.net>
References: <ada4ph6da05.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757269AbXJDUvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 16:51:14 -0400
In-Reply-To: <ada4ph6da05.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 04 Oct 2007 11:12:42 -0700

> Sorry for the lack of detail -- I've just switched to running in the
> console so if I can provoke the crash again I'll get a little more
> info.  I just wanted to mention this in case someone has seen
> something similar or has any good ideas about how to capture debugging
> output on a laptop (when I'm not home and have no other boxes handy).

I don't want to jump the gun on the analysis but it just might
be the packet sharing fixes Herbert put in a short time ago.

What you could do is go back to say rc2 and see if you still get
the panics, then bisect from there to narrow it down.

If rc2 still gives the panic, it's something else, perhaps device
specific.
