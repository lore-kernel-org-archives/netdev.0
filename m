From: David Miller <davem@davemloft.net>
Subject: Re: dynamically allocated dst_ops
Date: Wed, 29 Oct 2008 22:36:17 -0700 (PDT)
Message-ID: <20081029.223617.130281870.davem@davemloft.net>
References: <20081030042241.GA15999@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754678AbYJ3Fgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 01:36:42 -0400
In-Reply-To: <20081030042241.GA15999@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 30 Oct 2008 07:22:41 +0300

> They are bogus and should be implanted into struct net directly.
> In garbage collector hook, just use container_of() (once) to get struct net.
> ->dst_net is useless after that.
> 
> I'm going to use this trick for xfrm.

This sounds good to me :)
