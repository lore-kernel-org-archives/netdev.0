From: David Miller <davem@davemloft.net>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 05 Dec 2007 21:00:50 -0800 (PST)
Message-ID: <20071205.210050.86277995.davem@davemloft.net>
References: <20071205.053031.87154402.davem@davemloft.net>
	<4756B175.5010108@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750705AbXLFFAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:00:50 -0500
In-Reply-To: <4756B175.5010108@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner <jheffner@psc.edu>
Date: Wed, 05 Dec 2007 09:11:01 -0500

> FWIW, sounds similar to what these guys are doing with SIFTR for FreeBSD:
> http://caia.swin.edu.au/urp/newtcp/tools.html
> http://caia.swin.edu.au/reports/070824A/CAIA-TR-070824A.pdf

Yes, my proposal is very similar to this SIFTR work.

In their work they tap into the stack using the packet filtering
hooks.

In this way they avoid having to make TCP stack modifications, they
just look up the PCB and dump state, whereas we have more liberty to
do more serious surgery :-)
