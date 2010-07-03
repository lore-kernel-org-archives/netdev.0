From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH] cxgb4: Use kfree_skb for skb pointers
Date: Fri, 02 Jul 2010 22:28:51 -0700 (PDT)
Message-ID: <20100702.222851.59693056.davem@davemloft.net>
References: <20100701094552.GA6188@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57356
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045Ab0GCF2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 01:28:38 -0400
In-Reply-To: <20100701094552.GA6188@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Thu, 1 Jul 2010 09:45:52 +0000

> Use kfree_skb for skb pointers
> 
> Acked-by: Dimitris Michailidis <dm@chelsio.com> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

The code is completely different in this part of the driver now, this
patch does not apply.

In fact there is no reference to the string "kfree" at all in the
l2t.c file of the cxgb4 driver :)
