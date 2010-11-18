From: David Miller <davem@davemloft.net>
Subject: Re: [PATH] dev: reusing unregistered ifindex values in net_device
Date: Thu, 18 Nov 2010 08:01:39 -0800 (PST)
Message-ID: <20101118.080139.193717791.davem@davemloft.net>
References: <AANLkTinx6Ww4ZwRUTyYD_STPSRsSFck8O=W5yeJSbBs_@mail.gmail.com>
	<1290094628.2781.195.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.turull@gmail.com, netdev@vger.kernel.org, voravit@kth.se,
	robert@herjulf.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57432
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758396Ab0KRQBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 11:01:14 -0500
In-Reply-To: <1290094628.2781.195.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Nov 2010 16:37:08 +0100

> Two bugs 
> 
> 1) ifindex is not initialized : you'll be suprised of random values
> 
> 2) ifindex should not be reused. You'll be surprised so applications can
> break. SNMP comes to mind.

Right, the current algorithm is intentionally trying to avoid new
devices from using indexes that were used by another device in the
past.
