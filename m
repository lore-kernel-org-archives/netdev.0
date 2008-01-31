From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 20:25:21 +0100
Message-ID: <20080131192521.GG4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <47A212CB.1060403@hp.com> <20080131190326.GF4671@one.firstfloor.org> <47A214FE.3050200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48996 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756265AbYAaSuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:50:54 -0500
Content-Disposition: inline
In-Reply-To: <47A214FE.3050200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So, at what timescale do people using these qdiscs expect things to 
> appear "smooth?"  64KB of data at GbE speeds is something just north of 
> half a millisecond unless I've botched my units somewhere.

One typical use case for TBF is you talking to a DSL bridge that 
is connected using a GBit Ethernet switch. For these DSL connections it gives
much better behaviour to shape the traffic to slightly below
your external link speed so that you can e.g. prioritize packets properly.
But the actual external link speed is much lower than GbE.
A lot of GbE NICs enable TSO by default.

-Andi
