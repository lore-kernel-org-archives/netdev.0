From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is lost
Date: Tue, 3 Jun 2008 17:44:43 -0400
Message-ID: <20080603214443.GF16162@csclub.uwaterloo.ca>
References: <20080602165249.52a467dc@extreme> <20080603150524.GA16165@csclub.uwaterloo.ca> <20080603085707.51fdabbb@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:52350 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752262AbYFCVoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:44:44 -0400
Content-Disposition: inline
In-Reply-To: <20080603085707.51fdabbb@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 08:57:07AM -0700, Stephen Hemminger wrote:
> The patch makes carrier down == interface down. So the same
> behaviour as doing 'ip link set dev eth3 down'

That's what I thought from looking at it.

> If you are using a routing daemon like quagga, it will restore your static
> routes.

I never looked at using quagga to manage static routes. Perhaps I
should.

> That is pretty much what zebra portion of quagga does.

Hmm, other than zebra won't delete the route of the interface itself, it
seems to only touch routes it added.  Your patch would solve that
problem though.

-- 
Len Sorensen
