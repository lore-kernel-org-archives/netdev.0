From: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Thu, 24 May 2007 15:49:11 -0700
Message-ID: <46561667.1070105@pmc-sierra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Marc St-Jean <stjeanma@pmc-sierra.com>, akpm@linux-foundation.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from father.pmc-sierra.com ([216.241.224.13]:33401 "HELO
	father.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750741AbXEXWtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:49:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff Garzik wrote:
> Marc St-Jean wrote:
>  > I asked if the remaining section (above) was acceptable so we could 
> retain our
>  > buffer recycling which enhances throughput. I never received a rely 
> so it was
>  > left in my last patch.
>  >
>  > The above comment now answers my part of my initial question. Are you 
> aware of
>  > a better way to implement this or must we lose all our recycling 
> enhancements?
> 
> 
> You can poke around on netdev and ask about skb recycling in a new
> thread, and propose something.
> 
> I just know that having your own custom skb initialization is a
> non-starter.  Any updates the main skb init code receives will
> inevitably -not- be propagate to your code, rapidly leading to an
> unmaintainable disconnect.
> 
> skb recycling in general is an interesting area to explore, and others
> have poked around that area before.  I bet googling for skb recycling
> would turn up some useful thoughts and past efforts.
> 
>         Jeff
> 

I will resend the driver without the skb recycling shortly. We will need
to see if we can allocate resources to contribute to recycling at the
stack level later.

Thanks,
Marc
