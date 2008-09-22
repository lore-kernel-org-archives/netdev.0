From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 15:26:15 -0700 (PDT)
Message-ID: <20080922.152615.215876787.davem@davemloft.net>
References: <20080922.040912.193700258.davem@davemloft.net>
	<20080922203042.GY25711@one.firstfloor.org>
	<48D81A95.5080207@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54053
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752112AbYIVW01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 18:26:27 -0400
In-Reply-To: <48D81A95.5080207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>
Date: Mon, 22 Sep 2008 18:22:13 -0400

> How horrendous of a layering violation would it be to attach TCP
> performance parameters (either user-supplied or based on interface
> stats) to route table entries, like route metrics but intended to
> guide TCP autotuning?  It seems like it shouldn't be that hard to
> teach TCP that it doesn't need to optimize my lo connections much,
> and that it should be optimizing my eth0 subnet connections for
> lower latency and higher bandwidth than the connections that go
> through my gateway into the great beyond.

We already do this for other TCP connection parameters, and I tend to
think these delack/ato values belong there too.

If we add a global knob, people are just going to turn it on even if
they are also connected to the real internet on the system rather than
only internal networks they completely control.

That tends to cause problems.  It gets an entry on all of these bogus
"Linux performance tuning" sections administrators read from the
various financial messaging products.  So everyone does it without
thinking and using their brains.
