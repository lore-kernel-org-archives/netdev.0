From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next-2.6]: xfrm: Introduce
 LINUX_MIB_XFRMFWDHDRERROR
Date: Wed, 17 Feb 2010 13:49:46 -0800 (PST)
Message-ID: <20100217.134946.106752388.davem@davemloft.net>
References: <1266406852.3799.7.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754819Ab0BQVtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:49:31 -0500
In-Reply-To: <1266406852.3799.7.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 17 Feb 2010 06:40:52 -0500

>     xfrm: Introduce LINUX_MIB_XFRMFWDHDRERROR
>     
>     XFRMINHDRERROR counter is ambigous when validating forwarding
>     path. It makes it tricky to debug when you have both in and fwd
>     validation.
>     
>     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

This should be fine, the tools just parse the lines individually
as "string integer" pairs.

If you want to be super anal, add the new counter to the end of
the array.
