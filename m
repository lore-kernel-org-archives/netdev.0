From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery II
Date: Tue, 30 Mar 2010 08:17:57 +0200
Message-ID: <20100330061757.GN20695@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com> <1269898152.1958.86.camel@edumazet-laptop> <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com> <20100330052044.GJ20695@one.firstfloor.org> <1269929168.1958.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33143 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559Ab0C3GR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 02:17:58 -0400
Content-Disposition: inline
In-Reply-To: <1269929168.1958.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hmm, never mind your scheme of mapping it to the pmtudisc field would
probably work. Except it's u8 currently, would need to be u16 or u32

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
