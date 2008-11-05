From: David Miller <davem@davemloft.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Wed, 05 Nov 2008 15:10:15 -0800 (PST)
Message-ID: <20081105.151015.206163697.davem@davemloft.net>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
	<alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.blueman@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
To: swmike@swm.pp.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753729AbYKEXKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 18:10:39 -0500
In-Reply-To: <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikael Abrahamsson <swmike@swm.pp.se>
Date: Wed, 5 Nov 2008 23:20:25 +0100 (CET)

> So the upside of enabling it is minimal (I'd gladly see data proving
> the opposite) and the downside is a lot of trouble with lots of
> older devices which behave badly when ECN is enabled.

This kind of thinking just perpetuates the problem forever.

If nothing important on end nodes enables it by default, people
running core routers have no reason to turn it on, and so on and so
forth.

Linux is much bigger and smarter than that, so we should break
the loop and enable it by default some point soon.
