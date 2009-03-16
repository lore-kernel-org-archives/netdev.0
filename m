From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Sun, 15 Mar 2009 19:58:06 -0700 (PDT)
Message-ID: <20090315.195806.97939686.davem@davemloft.net>
References: <200903131017.11572.rusty@rustcorp.com.au>
	<20090313.120100.266753164.davem@davemloft.net>
	<200903141049.43202.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751851AbZCPC6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 22:58:19 -0400
In-Reply-To: <200903141049.43202.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 14 Mar 2009 10:49:42 +1030

> On Saturday 14 March 2009 05:31:00 David Miller wrote:
> > You can set netif_carrier_on() until you are blue in the face,
> > but until you hook up the ethtool link indication operation
> > NetworkManager won't see it.
> 
> Um, dude, you already have that patch in your net-next tree.  See below.
> This one goes on top.

Ahh, I didn't comprehend this bit.

I overreacted, that's for sure, sorry.

> Or should all devices which can't detect carrier set it to on, so
> older NetworkManagers work?

It is my opinion that this is the only correct behavior.

If you don't know, it's on.  Because "on" means "usable".  And you
can't fault NetworkManager or any other tool for making that kind of
decision.
