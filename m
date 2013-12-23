From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPV6: ip6_pol_route panic when doing interface up and down continuously with ipv6 traffic
Date: Mon, 23 Dec 2013 13:49:09 +0100
Message-ID: <20131223124909.GO14073@order.stressinduktion.org>
References: <CAOJFanWCwFuX8X0ubNXAaVma0XMwtW4Q5vG=ENvqWp0kYBaSzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "open list:ETHERNET BRIDGE" <netdev@vger.kernel.org>,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: Sasikanth babu <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47474 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757043Ab3LWMtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 07:49:10 -0500
Content-Disposition: inline
In-Reply-To: <CAOJFanWCwFuX8X0ubNXAaVma0XMwtW4Q5vG=ENvqWp0kYBaSzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 11:48:00AM +0530, Sasikanth babu wrote:
> I have been getting two kernel panics in ipv6 stack with 2.6.34.10
> kernel. One in ip6_pol_route and other one is in ip6_pkt_drop
> function. It is being observed when we did interface up and down
> continuously while ipv6 traffic going on.
> 
> I looked out for the patches and verified the kernel commit messages I
> could not find anything related to these panics.
> 
> Any suggestions?

Sorry, no, besides maybe trying a newer kernel.

Maybe some reference counting on the idev or dev being wrong. I am sure there
were some changes in recent kernels that might affect this.

Greetings,

  Hannes
