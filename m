From: Sebastien Jan <s-jan@ti.com>
Subject: Re: [PATCH] smsc95xx: Add module parameter to override MAC address
Date: Fri, 25 Jun 2010 16:20:36 +0200
Message-ID: <4C24BB34.3010601@ti.com>
References: <1277367254-9345-1-git-send-email-s-jan@ti.com> <20100625012520.GA12650@verge.net.au> <4C2452ED.8020307@ti.com>  <OF60E8D688.255F8F16-ON8025774D.002E17AA-8025774D.002FEC33@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Ian.Saturley@smsc.com" <Ian.Saturley@smsc.com>
To: "Steve.Glendinning@smsc.com" <Steve.Glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:46441 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756164Ab0FYOXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 10:23:17 -0400
In-Reply-To: <OF60E8D688.255F8F16-ON8025774D.002E17AA-8025774D.002FEC33@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steve,

Thanks for your answer.

On 06/25/2010 10:43 AM, Steve.Glendinning@smsc.com wrote:
[...]
> I can see you have a different use case, but I don't think this specific
> driver is the place for this logic.  I'd rather see it added to either
> the usbnet framework or (preferably) the netdev framework so *all*
> ethernet drivers can do this the same way.  otherwise we could end up
> with slight variations of this code in every single driver!

I perfectly understand your concerns. Unfortunately, I will probably not be
able to implement these changes into the netdev framework. However, I'd be 
happy to make some tests if someone proposes such changes.

