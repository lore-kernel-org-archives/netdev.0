From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 05 Jan 2010 13:40:38 -0800 (PST)
Message-ID: <20100105.134038.21223965.davem@davemloft.net>
References: <20100105185732.GA30346@redhat.com>
	<4B439299.1090205@gmail.com>
	<20100105205040.GA30921@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753504Ab0AEVke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 16:40:34 -0500
In-Reply-To: <20100105205040.GA30921@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 5 Jan 2010 22:50:40 +0200

> binding socket to device might be done by a separate process
> from the one doing sendmsg, and IMO the device socket is bound
> to might change at any time.
> 
> So the sending process would need to get socket name before
> each sendmsg.
> 
> Makes sense?

Not really, when it's at the expense of everyone else.

If you can pass the FD around, you can pass around auxiliary
information as well.

Make sense? :-)


