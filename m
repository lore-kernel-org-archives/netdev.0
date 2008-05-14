From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] Fix typo in net/core/sock.c.
Date: Wed, 14 May 2008 03:50:35 -0700 (PDT)
Message-ID: <20080514.035035.256243696.davem@davemloft.net>
References: <eb3ff54b0805140227h48fc5460hf00b1ff6eb080baa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755096AbYENKul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 06:50:41 -0400
In-Reply-To: <eb3ff54b0805140227h48fc5460hf00b1ff6eb080baa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Wed, 14 May 2008 12:27:47 +0300

> In sock_queue_rcv_skb()  (net/core/sock.c) it should be:
> "Cast sk->rcvbuf ..." instead of: "Cast skb->rcvbuf ..."
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Comment typo patches cannot cause regressions (usually :-)
so it's OK to add them to net-2.6

And therefore that's where I've applied this.

Thanks!
