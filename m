From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/802: indentation cleanup
Date: Fri, 24 Aug 2007 22:42:20 -0700 (PDT)
Message-ID: <20070824.224220.34754828.davem@davemloft.net>
References: <20070817185311.5564198a@freepuppy.rosehill.hemminger.net>
	<20070824.223940.56806419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756493AbXHYFmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 01:42:21 -0400
In-Reply-To: <20070824.223940.56806419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 24 Aug 2007 22:39:40 -0700 (PDT)

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 17 Aug 2007 18:53:11 -0700
> 
> > Run the 802 related protocols through Lindent (and hand cleanup)
> > to fix indentation and whitespace style issues.
> 
> Applied to net-2.6.24, thanks.

Actually reverted.

Nothing in the world makes me more furious than a "coding
style" change that wasn't even compile tested.

net/802/tr.c: In function $,1rx(Btr_add_rif_info$,1ry(B:
net/802/tr.c:400: error: expected identifier before $,1rx(B!$,1ry(B token

Stephen I see you do things like this, forget sign offs,
and many other things that all say in big huge letters
"sloppy".

Please shape up and test your changes no matter how trivial.

Thanks.
