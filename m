From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Use 1280 as min MTU for ipv6 forwarding
Date: Fri, 26 Feb 2010 04:34:59 -0800 (PST)
Message-ID: <20100226.043459.22651337.davem@davemloft.net>
References: <20100226092752.GA5969@babylon>
	<20100226.035947.242568281.davem@davemloft.net>
	<20100226123244.GB9114@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935302Ab0BZMel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:34:41 -0500
In-Reply-To: <20100226123244.GB9114@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Fri, 26 Feb 2010 13:32:44 +0100

> Clients will set their MTU to 1280 if they receive a
> ICMPV6_PKT_TOOBIG message with an MTU less than 1280.
> 
> To allow encapsulating of packets over a 1280 link
> we should always accept packets with a size of 1280
> for forwarding even if the path has a lower MTU and
> fragment the encapsulated packets afterwards.
> 
> In case a forwarded packet is not going to be encapsulated
> a ICMPV6_PKT_TOOBIG msg will still be send by ip6_fragment()
> with the correct MTU.
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>

Applied, thanks for fixing up this patch.
