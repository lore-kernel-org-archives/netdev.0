From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Tue, 20 Dec 2011 02:03:55 -0500 (EST)
Message-ID: <20111220.020355.942849877817117461.davem@davemloft.net>
References: <20111216122147.GJ6348@secunet.com>
	<20111219.161053.148816799233666803.davem@davemloft.net>
	<4EF030D5.6040603@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab1LTHEJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 02:04:09 -0500
In-Reply-To: <4EF030D5.6040603@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 20 Dec 2011 08:53:09 +0200

> Or maybe I missed the place where that updated would happen?

It should happen on every routing cache lookup hit just like we
validate the peer for redirect information.
