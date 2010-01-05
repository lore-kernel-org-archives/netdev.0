From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: why disable ipv6 on last address removal?
Date: Mon, 04 Jan 2010 22:44:36 -0800 (PST)
Message-ID: <20100104.224436.107234750.davem@davemloft.net>
References: <20091208192046.GA5649@midget.suse.cz>
	<20091208.125611.135547597.davem@davemloft.net>
	<4B1F5423.4070109@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753758Ab0AEGob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 01:44:31 -0500
In-Reply-To: <4B1F5423.4070109@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 09 Dec 2009 16:39:15 +0900

> Well, AFAIK, it is basically ancient thing.
> Some (rather new) paramters are exactly related bringing
> up each interface.
> 
> Such parameters should be set _before_ it is brought up.
> For now, people can do this using the "default" value.

I think we should retain inet6 device private structure after
we allocate it the first time that an ipv6 action occurs for
the device, exactly so that settings made earlier can be
retained.


