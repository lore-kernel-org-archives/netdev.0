From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Thu, 05 Jul 2007 18:45:02 +0200
Message-ID: <468D200E.1060200@trash.net>
References: <200707051618.l65GIh0J030375@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek@ihtfp.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35105 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758440AbXGEQpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 12:45:06 -0400
In-Reply-To: <200707051618.l65GIh0J030375@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> This cleanup fell out after adding L2TP support where a new encap_rcv
> funcptr was added to struct udp_sock. Have XFRM use the new encap_rcv
> funcptr, which allows us to move the XFRM encap code from udp.c into
> xfrm4_input.c.
> 
> Make xfrm4_rcv_encap() static since it is no longer called externally.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> ---
> Tested with L2TP and L2TP/IPsec.
> 
> Update after comments from Patrick. Fix encapsulated transport mode
> case and remove stupid file history comment change.


Looks good, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>
