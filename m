From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 16:12:37 +0200
Message-ID: <20100330141237.GP20695@one.firstfloor.org>
References: <4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com> <1269898152.1958.86.camel@edumazet-laptop> <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com> <20100330052044.GJ20695@one.firstfloor.org> <20100330061627.GA22436@laped.iglesias.mooo.com> <20100330061952.GO20695@one.firstfloor.org> <20100330082013.GA18300@edde.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40004 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979Ab0C3OMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 10:12:41 -0400
Content-Disposition: inline
In-Reply-To: <20100330082013.GA18300@edde.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Where does the application controllable per socket MTU come into the
> picture?

To set the minimum path MTU so that there is a guarantee that IPv6 routers
(which are unable to fragment themselves) will never drop it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
