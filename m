From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP changes for 2.6.18
Date: Tue, 06 Jun 2006 12:29:24 -0700 (PDT)
Message-ID: <20060606.122924.99202474.davem@davemloft.net>
References: <20060605110331.0f058738@dxpl.pdx.osdl.net>
	<20060605.165859.104035231.davem@davemloft.net>
	<20060606094655.6fd3711f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40405
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750985AbWFFT3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 15:29:23 -0400
To: shemminger@osdl.org
In-Reply-To: <20060606094655.6fd3711f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 6 Jun 2006 09:46:55 -0700

> On Mon, 05 Jun 2006 16:58:59 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > BTW, it seems we now have at least 3 instances "VEGAS + stuff"
> > and thus the core vegas logic is duplicated that many times.
> > Would be nice to have some core vegas infrastructure in the
> > generic congestion avoidance layer at some point.
> 
> Agreed, and the vegas stuff needs some work as well. It should
> have more smoothing like Westwood+

And that Westwood+ "smoothing" is the same sample smoothing algorithm
used in other parts of the generic TCP input processing, for example
in functions such as tcp_rtt_estimator() :-)
