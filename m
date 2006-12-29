From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Fri, 29 Dec 2006 15:20:53 -0800 (PST)
Message-ID: <20061229.152053.03108820.davem@davemloft.net>
References: <1165982844.11914.125.camel@localhost.localdomain>
	<20061228.210546.55150331.davem@davemloft.net>
	<1167428167.23340.114.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752879AbWL2XVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 18:21:19 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1167428167.23340.114.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 30 Dec 2006 08:36:07 +1100

> Heh, it's very possible it's a regression I added indeed. I'll try to
> have a look next week. Do you know of anybody who can verify on non-mii
> hardware or is pause irrelevant there ?

For PCS based PHY's most of the logic is taken care of internally,
and the pause-present signal is just sampled from one of the
PCS registers.

I think I have one here using non-mii that I could check at
some point :)
