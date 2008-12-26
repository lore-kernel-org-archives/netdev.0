From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/10] 802.3ad: remove public lacpdu_header
Date: Fri, 26 Dec 2008 13:45:37 -0800 (PST)
Message-ID: <20081226.134537.212403770.davem@davemloft.net>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
	<20081223220600.479443201@jonathan.eitzenberger.org>
	<20081226.134349.56490565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752926AbYLZVpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 16:45:35 -0500
In-Reply-To: <20081226.134349.56490565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 26 Dec 2008 13:43:49 -0800 (PST)

> From: Holger Eitzenberger <holger@eitzenberger.org>
> Date: Tue, 23 Dec 2008 23:01:09 +0100
> 
> > -	skb = dev_alloc_skb(length);
> > -	if (!skb) {
> > +	skb = dev_alloc_skb(len);
> > +	if (skb == NULL)
> 
> "!skb" is preferred to the long-winded "skb == NULL", so
> I'm tossing this patch and the rest which touch similar
> areas.

Also, I want to mention that your C++ comment conversions are not in
the proper coding style as well.  You are doing:

	/* something written
	   here */

instead of the proper:

	/* something written
	 * here
	 */

Just FYI...
