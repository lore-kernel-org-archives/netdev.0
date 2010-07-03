From: "Dimitrios Michailidis" <dm@chelsio.com>
Subject: RE: [RESEND][PATCH] cxgb4: Use kfree_skb for skb pointers
Date: Fri, 2 Jul 2010 22:51:17 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334081E3D00@maui.asicdesigners.com>
References: <20100701094552.GA6188@hera.kernel.org> <20100702.222851.59693056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <dkirjanov@hera.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8685 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab0GCFvl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 01:51:41 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Denis Kirjanov <dkirjanov@hera.kernel.org>
> Date: Thu, 1 Jul 2010 09:45:52 +0000
> 
> > Use kfree_skb for skb pointers
> >
> > Acked-by: Dimitris Michailidis <dm@chelsio.com>
> > Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> 
> The code is completely different in this part of the driver now, this
> patch does not apply.
> 
> In fact there is no reference to the string "kfree" at all in the
> l2t.c file of the cxgb4 driver :)

This patch is for net-next and it should apply there, I see the wrong
kfree (there's only one kfree).  Denis didn't mention net-next, maybe
you tried to apply it to net-2.6?
