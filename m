From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bit
Date: Fri, 31 Jan 2014 16:01:43 +0100
Message-ID: <20140131150143.GJ25336@order.stressinduktion.org>
References: <20140130142116.GD25336@order.stressinduktion.org> <20140130155945.GF25336@order.stressinduktion.org> <trinity-ece5a90d-72c2-4db9-a1f7-8c9af2bbfa65-1391156847114@3capp-gmx-bs01>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49476 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbaAaPBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 10:01:45 -0500
Content-Disposition: inline
In-Reply-To: <trinity-ece5a90d-72c2-4db9-a1f7-8c9af2bbfa65-1391156847114@3capp-gmx-bs01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 31, 2014 at 09:27:27AM +0100, Simon Schneider wrote:
> I think your IPv6 related statements are for a IPv6-over-IPv6 case.
>  
> However, I'm especially after the IPv6-over-IPv4 case.
>  
> In that case, you cannot copy the DF bit from the inner IPv6 packet.
>  
> But you still have the option to set or not set the DF bit in the IPv4 outer packet.
>  
> How is that decided?

Basically only pmtudisc setting is cruical then. So no DF-bit if nopmtudisc
and DF-bit if pmtudisc.

Greetings,

  Hannes
