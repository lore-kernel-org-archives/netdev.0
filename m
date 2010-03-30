From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 18:06:02 +0200
Message-ID: <20100330160602.GS20695@one.firstfloor.org>
References: <4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com> <1269898152.1958.86.camel@edumazet-laptop> <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com> <20100330052044.GJ20695@one.firstfloor.org> <20100330061627.GA22436@laped.iglesias.mooo.com> <20100330061952.GO20695@one.firstfloor.org> <E1829B60731D1740BB7A0626B4FAF0A649E05EABD5@XCH-NW-01V.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55845 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab0C3QGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 12:06:07 -0400
Content-Disposition: inline
In-Reply-To: <E1829B60731D1740BB7A0626B4FAF0A649E05EABD5@XCH-NW-01V.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Right again. Unlike IPv4, however, IPv6 does not allow
> in-the-network fragmentation. So when in doubt, apps
> that need to send isolated packets that may violate the
> path MTU should really perform host-based fragmentation
> with a maximum fragment size of 1280. Isn't there a
> socket option "IPV6_USE_MIN_MTU" that apps can use to
> force fragmentation on large packets (RFC3542)?

Thanks for the pointer. The option is right now only defined,
but not implemented.  But yes it would help. 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
