From: David Miller <davem@davemloft.net>
Subject: Re: Udp packets received with improper length
Date: Fri, 02 Dec 2011 21:54:01 -0500 (EST)
Message-ID: <20111202.215401.1831715862615853922.davem@davemloft.net>
References: <4ED3FBE8.2010006@conspiracy.net>
	<20111201.141136.1615370877653045134.davem@davemloft.net>
	<20111203023256.GA4259@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fsmail@conspiracy.net, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab1LCCzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:55:08 -0500
In-Reply-To: <20111203023256.GA4259@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 2 Dec 2011 19:32:57 -0700

> You are correct. What I had failed to see is the try_again case with
> multiple corruped datagrams. In this case the code is not correct,
> len could already have been modified in the previous
> iteration. Reverting the commit is the sanest option. Thank you.

Thanks for confirming my analysis.
