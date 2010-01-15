From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 01:18:29 -0800 (PST)
Message-ID: <20100115.011829.03057807.davem@davemloft.net>
References: <20100115.003636.199394610.davem@davemloft.net>
	<OF1B0853DD.2824263E-ON652576AC.002FA9D4-652576AC.0030AC47@LocalDomain>
	<OF0D3FEC3A.84663D58-ON652576AC.0031CA59-652576AC.003232CF@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51108
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755659Ab0AOJSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:18:20 -0500
In-Reply-To: <OF0D3FEC3A.84663D58-ON652576AC.0031CA59-652576AC.003232CF@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Fri, 15 Jan 2010 14:50:04 +0530

> I wonder if there is some other way to test it. I could test it on
> the card I have, cxgbe, by ethtool F_SG off, and then testing
> this patch with existing code (both with ethtool F_SG off)? Will
> that be enough to get an idea, or I cannot assume this is
> reasonable for real non-sg drivers? I am sure there is a
> degradation, and mentioned that part as a "penalty" for those
> drivers in my patch.

I think such a test would provide useful data by which to judge this
change.
