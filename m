From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 08:19:52 +0200
Message-ID: <20100330061952.GO20695@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com> <1269898152.1958.86.camel@edumazet-laptop> <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com> <20100330052044.GJ20695@one.firstfloor.org> <20100330061627.GA22436@laped.iglesias.mooo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33156 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755564Ab0C3GTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 02:19:53 -0400
Content-Disposition: inline
In-Reply-To: <20100330061627.GA22436@laped.iglesias.mooo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you don't want to hassle with all of that, the app can stick to
> 1280 (or I guess for the extreme/lazy cases turn on fragmentation)..

See the early mails in this thread. This is about apps who can't
limit themselves to 1280, but still don't want full blown PMTU.
[They probably should, but it can be a lot of work]

The MTU would allow to force fragmentation on the sending host
as a workaround similar to IPv4.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
