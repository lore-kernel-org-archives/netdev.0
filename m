From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] [TPROXY] fixes a possible read from an
 unmapped location in the socket match
Date: Sun, 07 Dec 2008 23:54:28 -0800 (PST)
Message-ID: <20081207.235428.206295036.davem@davemloft.net>
References: <1228674863.15263.82.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751206AbYLHHy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 02:54:27 -0500
In-Reply-To: <1228674863.15263.82.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Sun, 7 Dec 2008 11:16:53 +0100

> 	TIME_WAIT sockets need to be handled specially, and the socket match
> 	casted inet_timewait_sock instances to inet_sock, which are not
> 	compatible. Handle this special case by checking sk->sk_state.

There is no need to send this seperate version of the patch,
the bug fix will propagate automatically when I next merge
net-2.6 into net-next-2.6
