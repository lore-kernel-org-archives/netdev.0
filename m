From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TPROXY] fixes a possible read from an invalid
 location in the socket match
Date: Sun, 07 Dec 2008 23:54:00 -0800 (PST)
Message-ID: <20081207.235400.112829427.davem@davemloft.net>
References: <1228675414.15263.102.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hidden@sch.bme.hu
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37295
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbYLHHx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 02:53:59 -0500
In-Reply-To: <1228675414.15263.102.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Sun, 07 Dec 2008 19:43:34 +0100

> I've found this while looking for an unrelated issue. I guess this should 
> still go in 2.6.28, if possible.
> 
> TIME_WAIT sockets need to be handled specially, and the socket match
> casted inet_timewait_sock instances to inet_sock, which are not
> compatible. 
> 
> Handle this special case by checking sk->sk_state.
> 
> Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>

Applied, thanks.
