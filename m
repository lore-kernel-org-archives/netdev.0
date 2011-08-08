From: Chris Adams <cmadams@hiwaay.net>
Subject: Re: 802.3ad bonding brain damaged?
Date: Mon, 8 Aug 2011 15:08:53 -0500
Message-ID: <20110808200853.GE19763@hiwaay.net>
References: <4E3EECF6.90409@cfl.rr.com> <1312790234.7020.26.camel@arkology.n2.diac24.net> <4E4041B5.5040908@cfl.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fly.hiwaay.net ([216.180.54.1]:39377 "EHLO fly.hiwaay.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424Ab1HHUON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 16:14:13 -0400
Received: from fly.hiwaay.net (localhost.localdomain [127.0.0.1])
	by fly.hiwaay.net (8.13.8/8.13.8/fly) with ESMTP id p78K8raa018224
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 15:08:53 -0500
Received: (from cmadams@localhost)
	by fly.hiwaay.net (8.13.8/8.13.8/fly-submit) id p78K8rmO018223
	for netdev@vger.kernel.org; Mon, 8 Aug 2011 15:08:53 -0500
Content-Disposition: inline
In-Reply-To: <4E4041B5.5040908@cfl.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once upon a time, Phillip Susi <psusi@cfl.rr.com> said:
> On 8/8/2011 3:57 AM, David Lamparter wrote:
> >No, it isn't. 802.3ad/.1AX explicitly requires that no packet
> >re-ordering may ever occur, which can only be guaranteed by enqueueing
> >packets for one host on one TX interface. This behaviour is mandated by
> >802.1AX-2008 page 15 which reads:
> 
> Outch, that does cause a big problem for store-and-forward switching. 
> You basically can't split up packets from a single stream without very 
> careful cut-through switching, which we obviously can't do in Linux. 
> That seems a rather silly requirement given that higher level protocols 
> already deal with packet reordering.  Why not an option to say stuff the 
> standard?

Packet reordering introduces jitter, which is bad for things like VOIP.
-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
