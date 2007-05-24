From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Thu, 24 May 2007 18:25:36 -0400
Message-ID: <465610E0.6020309@garzik.org>
References: <46560E06.9090506@pmc-sierra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc St-Jean <stjeanma@pmc-sierra.com>, akpm@linux-foundation.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48720 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbXEXW0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 18:26:11 -0400
In-Reply-To: <46560E06.9090506@pmc-sierra.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marc St-Jean wrote:
> I asked if the remaining section (above) was acceptable so we could retain our
> buffer recycling which enhances throughput. I never received a rely so it was
> left in my last patch.
> 
> The above comment now answers my part of my initial question. Are you aware of
> a better way to implement this or must we lose all our recycling enhancements?


You can poke around on netdev and ask about skb recycling in a new 
thread, and propose something.

I just know that having your own custom skb initialization is a 
non-starter.  Any updates the main skb init code receives will 
inevitably -not- be propagate to your code, rapidly leading to an 
unmaintainable disconnect.

skb recycling in general is an interesting area to explore, and others 
have poked around that area before.  I bet googling for skb recycling 
would turn up some useful thoughts and past efforts.

	Jeff


