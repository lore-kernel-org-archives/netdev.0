From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 08 Sep 2008 23:02:21 -0700 (PDT)
Message-ID: <20080908.230221.101659829.davem@davemloft.net>
References: <48C6052D.2080203@redhat.com>
	<20080908.221742.02572583.davem@davemloft.net>
	<48C60FFC.8090109@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753325AbYIIGC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 02:02:28 -0400
In-Reply-To: <48C60FFC.8090109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>
Date: Tue, 09 Sep 2008 01:56:12 -0400

[ Please hit enter every 80 columns or so, your emails are
  unreadable until I reformat your text by hand, thanks. ]

> That's not the problem I'm talking about here.  The problem I'm
> seeing is that if your burst of messages is too small to fill the
> MTU, the network stack will just sit there and stare at you for
> precisely 40 ms (an eternity for a financial app) before
> transmitting.  Andi may be correct that it's actually the delayed
> ACK we're seeing, but I can't figure out where that 40 ms magic
> number is coming from.
>
> The easiest way to see the problem is to open a TCP socket to an
> echo daemon on loopback, make a bunch of small writes totaling less
> than your loopback MTU (accounting for overhead), and see how long
> it takes to get your echoes.  You can probably do this with netcat,
> though I haven't tried.  People don't expect loopback to have 40 ms
> latency when the box is lightly loaded, so they'd really like to
> tweak that down when it's hurting them.

That's informative, but please provide a specific test case and
example trace so we can discuss something concrete.

Thank you.
