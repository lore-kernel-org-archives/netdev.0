From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PPPOL2TP] add missing sock_put() in
 pppol2tp_tunnel_closeall()
Date: Mon, 03 Mar 2008 20:49:44 -0800 (PST)
Message-ID: <20080303.204944.230055609.davem@davemloft.net>
References: <47C402A2.8040401@katalix.com>
	<20080227114837.GA5795@ff.dom.local>
	<47CB0EE9.9060707@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbYCDEtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 23:49:45 -0500
In-Reply-To: <47CB0EE9.9060707@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Sun, 02 Mar 2008 20:32:41 +0000

> Jarek Poplawski wrote:
> > 
> > Subject: [PPPOL2TP] add missing sock_put() in pppol2tp_tunnel_closeall()
> > 
> > Every skb removed from session->reorder_q needs sock_put().
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Acked-by: James Chapman <jchapman@katalix.com>

Also applied, thanks everyone.
