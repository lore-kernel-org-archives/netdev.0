From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] [TPROXY] kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Wed, 10 Dec 2008 00:57:28 -0800 (PST)
Message-ID: <20081210.005728.41175879.davem@davemloft.net>
References: <1228812695.7631.16.camel@bzorp.balabit>
	<20081209.221838.206534714.davem@davemloft.net>
	<1228899142.7542.31.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tproxy@lists.balabit.hu, hidden@sch.bme.hu,
	panther@balabit.hu
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754898AbYLJI51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 03:57:27 -0500
In-Reply-To: <1228899142.7542.31.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Wed, 10 Dec 2008 09:52:22 +0100

> I understand. Here are the alternatives I considered:
>  1) the patch above, by extending the socket structures
>  2) expand skb, of course I felt this is worse than the patch I posted
>  3) call inet_twsk_deschedule() from the prerouting hook
> 
> The 3rd one does not require any expansion of the related structures,
> however it'd mean that the TCP state is not only looked up, but also
> changed from the TPROXY target. I felt this ugly, but the ugliness would
> be constrained to the tproxy code. Shall I post a patch implementing
> option #3 above?

It would be interesting to see what it looks like, so if you
don't mind then yes please toss that together so we can have
a look.
