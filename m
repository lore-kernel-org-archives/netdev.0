From: David Miller <davem@davemloft.net>
Subject: Re: netif_schedule and mpc5200_fec
Date: Tue, 22 Jul 2008 14:11:51 -0700 (PDT)
Message-ID: <20080722.141151.145185759.davem@davemloft.net>
References: <9e4733910807221247r38509c76uf625195b712a1145@mail.gmail.com>
	<9e4733910807221403g512f6e37s6722c7950f881224@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, davem@redhat.com
To: jonsmirl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35962
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750855AbYGVVLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:11:51 -0400
In-Reply-To: <9e4733910807221403g512f6e37s6722c7950f881224@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jon Smirl" <jonsmirl@gmail.com>
Date: Tue, 22 Jul 2008 17:03:32 -0400

> On 7/22/08, Jon Smirl <jonsmirl@gmail.com> wrote:
> > I just updated to linus/master and mpc5200_fec won't boot.
> 
> It does boot, but this badness looks like it is coming from this
> patch. I don't know enough about networking to debug it.

The driver is doing a netif_wake_queue() when it should not.
I'll have a more detailed look at this and try to fix it
later.
