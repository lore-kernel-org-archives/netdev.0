From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED] act_gact: division by zero
Date: Thu, 30 Nov 2006 15:05:53 +0100
Message-ID: <456EE541.6010904@trash.net>
References: <Pine.LNX.4.44.0611301530590.4036-100000@dhcp09282.ntc.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32460 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936415AbWK3OGA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 09:06:00 -0500
To: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
In-Reply-To: <Pine.LNX.4.44.0611301530590.4036-100000@dhcp09282.ntc.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nordlund Kim (Nokia-NET/Helsinki) wrote:
> On Thu, 30 Nov 2006, ext Patrick McHardy wrote:
> 
>>I think it should reject an invalid configuration or handle
>>the zero case correctly by not dividing.
> 
> 
> You are correct. Not returning -EINVAL, because someone might
> want to use the value zero in some future gact_prob algorithm?

That looks good, thanks.
