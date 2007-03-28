From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Rexmit hint must be cleared instead of setting
 it
Date: Wed, 28 Mar 2007 12:39:44 -0700 (PDT)
Message-ID: <20070328.123944.68041231.davem@davemloft.net>
References: <20070328.120709.35017257.davem@davemloft.net>
	<20070328.121405.49244759.davem@davemloft.net>
	<Pine.LNX.4.64.0703282223540.29833@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965699AbXC1Tjo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 15:39:44 -0400
In-Reply-To: <Pine.LNX.4.64.0703282223540.29833@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 28 Mar 2007 22:29:05 +0300 (EEST)

> ...but lets keep in mind that the actual goal is, of course, to get r=
id of=20
> the hint altogether, rather than doing these clearing things... :-)

Of course.

The retranmit and forward SKB hints should be easy to kill.
In the worst case we can use the cached SACK sequence numbers
and perhaps one auxiliary sequence number hint to guide the
RB tree search for SKBs to retransmit.

A space intensive, and therefore not very appealing, scheme
is to have a linked list of SKBs which have been marked lost.
