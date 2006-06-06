From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP changes for 2.6.18
Date: Tue, 6 Jun 2006 09:46:55 -0700
Message-ID: <20060606094655.6fd3711f@localhost.localdomain>
References: <20060605110331.0f058738@dxpl.pdx.osdl.net>
	<20060605.165859.104035231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42696 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750896AbWFFQrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 12:47:05 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060605.165859.104035231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Jun 2006 16:58:59 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Mon, 5 Jun 2006 11:03:31 -0700
> 
> > Dave, please consider adding these for the 2.6.18.
> 
> I'll pick these into my tree by extracting out the patches.
> Your tree wasn't based upon the net-2.6.18 tree, so if I just
> pull it into mine I'll get all the upstream changes since I
> cut the net-2.6.18 which at the current time I don't want :)
>

I will rebase it on your tree today.
 
> BTW, it seems we now have at least 3 instances "VEGAS + stuff"
> and thus the core vegas logic is duplicated that many times.
> Would be nice to have some core vegas infrastructure in the
> generic congestion avoidance layer at some point.

Agreed, and the vegas stuff needs some work as well. It should
have more smoothing like Westwood+
