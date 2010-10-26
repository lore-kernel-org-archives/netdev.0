From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:21:45 -0700 (PDT)
Message-ID: <20101026.102145.246528067.davem@davemloft.net>
References: <4CC708CE.4040404@hp.com>
	<20101026.101038.260090183.davem@davemloft.net>
	<AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757700Ab0JZRVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:21:22 -0400
In-Reply-To: <AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 26 Oct 2010 10:13:45 -0700

> Removing autoconfigured addresses is what the kernel currently does
> when the link goes down. The patch just makes sure it happens when
> carrier is lost as well, since losing link might mean that when
> carrier comes back, the host might be on a different link than it was
> before.

I just think validating that fact would be a better approach than
simply assuming link down/up means link change.
