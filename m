From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Wed, 27 Oct 2010 08:51:15 -0700 (PDT)
Message-ID: <20101027.085115.104074771.davem@davemloft.net>
References: <AANLkTikFnwM9Ks6h1Jb0+pNW6rkmcKnbVNzKdXUqPnHU@mail.gmail.com>
	<20101026.112321.258116003.davem@davemloft.net>
	<AANLkTik2Q=fF9j6eiBQx33e2JU7EG3Sc5hnXyDH24+mt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46929
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754748Ab0J0Puw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 11:50:52 -0400
In-Reply-To: <AANLkTik2Q=fF9j6eiBQx33e2JU7EG3Sc5hnXyDH24+mt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 26 Oct 2010 15:53:50 -0700

> As the patch stands, they don't. Only autoconfigured addresses will be
> cleared, because addrconf_ifdown() does not remove any addresses that
> are permanent (unless they are link-local, in which case they are
> recreated as soon as link comes back).

Ok, and that brings us back to the issue of losing a TCP connection
over a link-local et al. address during a minor link flap.

I think some financial services people will really dislike that
behavior :)
