From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Wed, 14 Dec 2011 12:50:10 -0500 (EST)
Message-ID: <20111214.125010.82857701285437834.davem@davemloft.net>
References: <4EE8C6A8.3060308@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757738Ab1LNRuU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 12:50:20 -0500
In-Reply-To: <4EE8C6A8.3060308@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 14 Dec 2011 17:54:16 +0200

> So something is does not get updated here. This used to work though.
> The current production boxes where I know this work is 2.6.38.8.

We store the PMTU externally in inetpeer entries, Eric Dumazet
fixed recently but that fix hasn't been submitted to -stable
yet.

I'd recommend using 3.1.x if possible if you can't wait.
