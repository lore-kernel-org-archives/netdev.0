From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Thu, 05 Jul 2007 17:08:18 -0700 (PDT)
Message-ID: <20070705.170818.62675018.davem@davemloft.net>
References: <200707051618.l65GIh0J030375@quickie.katalix.com>
	<468D200E.1060200@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org, derek@ihtfp.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759720AbXGFAH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 20:07:58 -0400
In-Reply-To: <468D200E.1060200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Jul 2007 18:45:02 +0200

> James Chapman wrote:
> > This cleanup fell out after adding L2TP support where a new encap_rcv
> > funcptr was added to struct udp_sock. Have XFRM use the new encap_rcv
> > funcptr, which allows us to move the XFRM encap code from udp.c into
> > xfrm4_input.c.
> > 
> > Make xfrm4_rcv_encap() static since it is no longer called externally.
> > 
> > Signed-off-by: James Chapman <jchapman@katalix.com>
> > 
> > ---
> > Tested with L2TP and L2TP/IPsec.
> > 
> > Update after comments from Patrick. Fix encapsulated transport mode
> > case and remove stupid file history comment change.
> 
> 
> Looks good, thanks.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks everyone.
