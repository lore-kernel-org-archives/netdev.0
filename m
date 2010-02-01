From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3][v2] tcp: fix ICMP-RTO war
Date: Sun, 31 Jan 2010 23:33:38 -0800 (PST)
Message-ID: <20100131.233338.254690877.davem@davemloft.net>
References: <4B635E17.406@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52377
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752703Ab0BAHdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 02:33:25 -0500
In-Reply-To: <4B635E17.406@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Fri, 29 Jan 2010 23:15:51 +0100

> This patches fix the current RTO calculation routine, when
> srtt and rttvar are zero, yielding an RTO of zero 
> Under some circumstances, TCPs srtt and rttvar are zero,
> yielding a calculated RTO of zero.
> This is particularly unfortunate for ICMP based RTO recalculation
> as introduced in f1ecd5d9e736660 (Revert Backoff [v3]: Revert RTO
> on ICMP destination unreachable), as it results in RTO retransmission
> flooding.
> 
> Thanks to Ilpo Jarvinen for providing debug patches and to
> Denys Fedoryshchenko for reporting and testing.
> 
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

I still haven't seen a detailed enough analysis of why these
tiny RTOs can come to exist in the first place.

Please show me a list of events, function by function, the value of
relevant variables and per-socket TCP state, in the TCP stack, that
show how this ends up happening.

Thanks for all of your work on this so far.
