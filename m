From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]xfrm: Flushing empty SAD generates false events
Date: Mon, 15 Feb 2010 21:54:34 -0800 (PST)
Message-ID: <20100215.215434.241477399.davem@davemloft.net>
References: <1265881887.3988.4.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752166Ab0BPFyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:54:18 -0500
In-Reply-To: <1265881887.3988.4.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Thu, 11 Feb 2010 04:51:27 -0500

>     xfrm: Flushing empty SAD generates false events
>     
>     To see the effect make sure you have an empty SAD.
>     On window1 "ip xfrm mon" and on window2 issue "ip xfrm state flush"
>     You get prompt back in window1 and you see the flush event on window2.
>     With this fix, you still get prompt on window1 but no event on window2.
>     
>     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied to net-next-2.6
