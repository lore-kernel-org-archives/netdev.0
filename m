From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Tue, 08 Jul 2008 15:37:42 -0700 (PDT)
Message-ID: <20080708.153742.124166123.davem@davemloft.net>
References: <4873CAFB.8040606@trash.net>
	<20080708.150257.41516850.davem@davemloft.net>
	<4873E7B9.2020304@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, nico@cam.org, dale@farnsworth.org,
	akarkare@marvell.com, jdb@comx.dk, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751567AbYGHWhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:37:42 -0400
In-Reply-To: <4873E7B9.2020304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 09 Jul 2008 00:18:33 +0200

> David Miller wrote:
> > Patrick, want me to stuff this one into net-2.6?
> >
> > BTW, there is a typo in the commit message, you say
> > "skb_cow_header()" which doesn't exist, you mean "skb_cow_head()".
> > But you got it right in the code :)
> >   
> 
> I would feel better putting it in net-next-2.6.git. The code
> currently doesn't handle shared skbs and it does look unnecessary.
> But if we actually get one it will BUG in pskb_expand_head().

Ok, applied to net-next-2.6 and I took care of the commit
typo.

Thanks!
