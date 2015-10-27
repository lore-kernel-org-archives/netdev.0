From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 06:42:28 -0700 (PDT)
Message-ID: <20151027.064228.237119117273824839.davem@davemloft.net>
References: <20151024023054.GZ22011@ZenIV.linux.org.uk>
	<201510270908.t9R9873a001683@room101.nl.oracle.com>
	<562F577E.6000901@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266AbbJ0NZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 09:25:49 -0400
In-Reply-To: <562F577E.6000901@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Tue, 27 Oct 2015 10:52:46 +0000

> an implicit shutdown() it would mean that well-written applications
> that handled the scoping, sharing and reuse of FDs properly could just
> call close() and have it work the same way across *NIX platforms.

This semantic would only exist after Linux version X.Y.Z and vendor
kernels that decided to backport the feature.

Ergo, this application would ironically be non-portable on Linux
machines.

If portable Linux applications have to handle the situation using
existing facilities there is absolutely zero value to add it now
because it only will add more complexity to applications handling
things correctly because they will always have two cases to somehow
conditionally handle under Linux.

And if the intention is to just always assume the close() semantic
thing is there, then you have given me a disincentive to ever add the
facility.
