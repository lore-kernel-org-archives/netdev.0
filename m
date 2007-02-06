From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 17:54:04 -0800 (PST)
Message-ID: <20070205.175404.23014614.davem@davemloft.net>
References: <45C7B77B.9060506@psc.edu>
	<20070205.150815.112291591.davem@davemloft.net>
	<45C7C79D.1070707@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965320AbXBFByG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 20:54:06 -0500
In-Reply-To: <45C7C79D.1070707@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Mon, 05 Feb 2007 19:11:09 -0500

> My first patch was broken anyway (should not have pulled the test from 
> tso_should_defer), and the change is not needed to the nagle test since 
> it's implicit.  This patch just restores the old behavior from before 
> TSO, sending the FIN when it's the last true segment.  We can debate the 
> merits of applying congestion control to the FIN separately. :)

Yes, let's split one hair at a time :-)

Patch applied, thanks John.  I'll push this to the 2.6.x -stable
branch too.
