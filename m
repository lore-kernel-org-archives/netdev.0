From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/5] ipv6: make the protocol initialization to return
 an error code
Date: Tue, 11 Dec 2007 02:25:52 -0800 (PST)
Message-ID: <20071211.022552.157588535.davem@davemloft.net>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071210151440.241406358@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbXLKKZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:25:53 -0500
In-Reply-To: <20071210151440.241406358@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 10 Dec 2007 16:09:15 +0100

> This patchset makes the different protocols to return an error code, so
> the af_inet6 module can check the initialization was correct or not.
> 
> The raw6 was taken into account to be consistent with the rest of the
> protocols, but the registration is at the same place.
> Because the raw6 has its own init function, the proto and the ops structure
> can be moved inside the raw6.c file.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Also applied, thanks Daniel.
