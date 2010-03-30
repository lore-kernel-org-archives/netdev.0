From: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 10:20:13 +0200
Message-ID: <20100330082013.GA18300@edde.se.axis.com>
References: <877how25kx.fsf@basil.nowhere.org>
 <4BB0DCF6.9020401@hp.com>
 <20100329201431.GH20695@one.firstfloor.org>
 <20100329205035.GA32656@laped.iglesias.mooo.com>
 <4BB11510.9000302@hp.com>
 <1269898152.1958.86.camel@edumazet-laptop>
 <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
 <20100330052044.GJ20695@one.firstfloor.org>
 <20100330061627.GA22436@laped.iglesias.mooo.com>
 <20100330061952.GO20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:48744 "EHLO
	miranda.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960Ab0C3IZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 04:25:13 -0400
Content-Disposition: inline
In-Reply-To: <20100330061952.GO20695@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 08:19:52AM +0200, Andi Kleen wrote:
> > If you don't want to hassle with all of that, the app can stick to
> > 1280 (or I guess for the extreme/lazy cases turn on fragmentation)..
> 
> See the early mails in this thread. This is about apps who can't
> limit themselves to 1280, but still don't want full blown PMTU.
> [They probably should, but it can be a lot of work]
> 
> The MTU would allow to force fragmentation on the sending host
> as a workaround similar to IPv4.

Yes, but I dont see why you need an option with semantics of setting an MTU.

If an UDP app wants to use fragmentation (for whatever reason) setting
a boolean flag like XXX_PMTUDISC_DONT should be enough. The kernel will for
IPv6 have to work with the real PMTU or stick to 1280 when generating the
fragments. Keep in mind that unlike IPv4, IPv6 has no DF flag. It's up to
the sender to create the the fragments.

Where does the application controllable per socket MTU come into the
picture?

Cheers
